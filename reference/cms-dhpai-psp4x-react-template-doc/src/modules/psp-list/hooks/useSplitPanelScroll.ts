import { useRef, useEffect, useMemo, useState, useCallback } from "react";
import {
	createScrollAccelerator,
	type ScrollAccelerationConfig,
} from "../utils/scrollAcceleration";
import { useEffectEvent } from "./useEffectEvent";

// =============================================================================
// DEBUG FLAGS - Set to true to disable features during debugging
// =============================================================================
const DEBUG_DISABLE_ACCELERATION = false;
// =============================================================================

// #region agent log
const _DBG_ENDPOINT =
	"http://127.0.0.1:7242/ingest/14ec58d7-a42d-48a0-b5df-766ce3885083";
const _dbgCounters = {
	wheelTotal: 0,
	wheelProcessed: 0,
	wheelDropped: 0,
	nativeScrollTotal: 0,
	nativeScrollProcessed: 0,
	nativeScrollBlocked: 0,
	effectRuns: 0,
	rafResets: 0,
};
const _dbg = (msg: string, data: Record<string, unknown>, hyp: string) => {
	fetch(_DBG_ENDPOINT, {
		method: "POST",
		headers: { "Content-Type": "application/json" },
		body: JSON.stringify({
			location: "useSplitPanelScroll.ts",
			message: msg,
			data,
			timestamp: Date.now(),
			sessionId: "debug-session",
			hypothesisId: hyp,
		}),
	}).catch(() => {});
};
// #endregion

export interface SplitPanelScrollConfig {
	/** Enable scroll acceleration. Default: true (but overridden by DEBUG flag) */
	enableAcceleration?: boolean;
	/** Custom acceleration config */
	accelerationConfig?: Partial<ScrollAccelerationConfig>;
	/** Row height in pixels (for scrollToRowIndex calculation) */
	rowHeight: number;
	/**
	 * Use native browser scrolling instead of intercepting wheel/touch events.
	 * When true, the browser handles scrolling on its compositor thread (GPU-accelerated,
	 * no main-thread blocking) and panels are synced via native scroll events.
	 * Best used with `disableVirtualization` on the DataGrid — all rows are already
	 * in the DOM so native scrolling works perfectly with zero JavaScript overhead.
	 * Default: false (use wheel interception for scroll acceleration + sync).
	 */
	nativeScroll?: boolean;
}

/**
 * Minimal GridApi interface required for scroll synchronization.
 * Works with both GridApiCommunity and GridApiPro.
 */
interface GridApiWithRootRef {
	rootElementRef?: {
		current: HTMLDivElement | null;
	};
}

export interface UseSplitPanelScrollOptions {
	/** API refs for all DataGrid instances to synchronize */
	apiRefs: ReadonlyArray<React.MutableRefObject<GridApiWithRootRef | null>>;
	/** Scroll configuration */
	config: SplitPanelScrollConfig;
}

export interface UseSplitPanelScrollResult {
	/** Scroll to make a specific row index visible (used by keyboard navigation) */
	scrollToRowIndex: (rowIndex: number, totalRows: number) => void;
	/** Current scroll position (for debugging/external use) */
	scrollTop: number;
}

const VIRTUAL_SCROLLER_SELECTOR = ".MuiDataGrid-virtualScroller";

const getScrollerElement = (
	apiRef: React.MutableRefObject<GridApiWithRootRef | null>,
): HTMLElement | null =>
	apiRef.current?.rootElementRef?.current?.querySelector<HTMLElement>(
		VIRTUAL_SCROLLER_SELECTOR,
	) ?? null;

/**
 * Unified hook for synchronizing scroll across multiple DataGridPro panels.
 *
 * Handles three scroll input sources:
 * 1. Mouse wheel / trackpad scrolling
 * 2. Scrollbar dragging (on the rightmost panel)
 * 3. Keyboard navigation (via scrollToRowIndex)
 *
 * All scroll operations are synchronous - all panels update in the same frame.
 *
 * @remarks
 * **Assumption**: All synchronized elements must have the same scroll height
 * (i.e., same number of rows with same row heights).
 */
export function useSplitPanelScroll({
	apiRefs,
	config,
}: UseSplitPanelScrollOptions): UseSplitPanelScrollResult {
	const {
		enableAcceleration = true,
		accelerationConfig,
		rowHeight,
		nativeScroll = false,
	} = config;

	// Effective acceleration setting (respects debug flag)
	const effectiveEnableAcceleration = DEBUG_DISABLE_ACCELERATION
		? false
		: enableAcceleration;

	// Single source of truth for scroll position
	const scrollStateRef = useRef({ scrollTop: 0, maxScroll: 0 });
	// Guard for when OUR code initiates scroll (wheel/touch/keyboard)
	// In this case, block ALL native scroll events until next frame
	const isOwnScrollRef = useRef(false);
	// Track which element initiated native scrolling (scrollbar drag)
	// This allows continued scrolling from source while blocking cascaded events
	const syncSourceRef = useRef<HTMLElement | null>(null);
	const syncResetRafRef = useRef<number | null>(null); // Track RAF to cancel duplicates
	const [retryCount, setRetryCount] = useState(0);

	// RAF batching for wheel/touch: accumulate deltas and apply once per frame
	const pendingDeltaRef = useRef(0);
	const wheelRafRef = useRef<number | null>(null);

	// Create accelerator once (stable reference)
	const [accelerator] = useState(() =>
		createScrollAccelerator(accelerationConfig),
	);

	// Get all scroller elements
	const elements = useMemo(
		() => apiRefs.map(getScrollerElement),
		// eslint-disable-next-line react-hooks/exhaustive-deps
		[apiRefs, retryCount],
	);

	// Filter to only valid (non-null) elements
	const validElements = useMemo(
		() => elements.filter((el): el is HTMLElement => el !== null),
		[elements],
	);

	const allElementsReady = validElements.length === apiRefs.length;

	// ==========================================================================
	// Core scroll helpers (declared before init effect so they can be referenced)
	// ==========================================================================

	/**
	 * Get the MINIMUM max scroll position across all panels.
	 * This ensures we never set a scrollTop that any panel will clamp,
	 * preventing desync caused by browser clamping triggering scroll events.
	 * (All panels have same scrollHeight, but clientHeight may differ
	 * due to horizontal scrollbar visibility differences)
	 */
	const getMaxScroll = useCallback(() => {
		if (validElements.length === 0) return 0;
		let minMaxScroll = Infinity;
		for (const el of validElements) {
			const elMaxScroll = Math.max(el.scrollHeight - el.clientHeight, 0);
			if (elMaxScroll < minMaxScroll) {
				minMaxScroll = elMaxScroll;
			}
		}
		return minMaxScroll === Infinity ? 0 : minMaxScroll;
	}, [validElements]);

	/**
	 * Get the MINIMUM visible height across all panel viewports.
	 * This ensures that when we calculate row visibility, the row is visible
	 * in ALL panels, not just one. Panels may have different clientHeight
	 * when horizontal scrollbars differ (one shows, one doesn't).
	 */
	const getViewportHeight = useCallback(() => {
		if (validElements.length === 0) return 0;
		let minHeight = Infinity;
		for (const el of validElements) {
			if (el.clientHeight < minHeight) {
				minHeight = el.clientHeight;
			}
		}
		return minHeight === Infinity ? 0 : minHeight;
	}, [validElements]);

	/**
	 * Schedule the sync guard reset for next frame.
	 * Cancels any previous pending reset to prevent RAF accumulation.
	 */
	const scheduleSyncReset = useCallback(() => {
		// Cancel any pending reset
		if (syncResetRafRef.current !== null) {
			cancelAnimationFrame(syncResetRafRef.current);
		}
		// Schedule new reset
		syncResetRafRef.current = requestAnimationFrame(() => {
			isOwnScrollRef.current = false;
			syncSourceRef.current = null;
			syncResetRafRef.current = null;
			// #region agent log
			_dbgCounters.rafResets++;
			// #endregion
		});
	}, []);

	/**
	 * CORE FUNCTION: Apply scroll position to ALL panels synchronously.
	 * This is the single point where scroll sync happens.
	 */
	const applyScrollToAll = useCallback(
		(scrollTop: number) => {
			if (!allElementsReady) return;

			// Clamp to valid range
			const maxScroll = getMaxScroll();
			const clampedScrollTop = Math.max(0, Math.min(scrollTop, maxScroll));

			// Update our source of truth
			scrollStateRef.current.scrollTop = clampedScrollTop;
			scrollStateRef.current.maxScroll = maxScroll;

			// Synchronously update all panels (same frame)
			for (const el of validElements) {
				el.scrollTop = clampedScrollTop;
			}
		},
		[allElementsReady, getMaxScroll, validElements],
	);

	// Retry when elements become available
	useEffect(() => {
		if (!allElementsReady) {
			const timer = setTimeout(() => setRetryCount((n) => n + 1), 100);
			return () => clearTimeout(timer);
		}
		// Initialize scroll position and maxScroll from first element
		const firstElement = validElements[0];
		if (firstElement) {
			scrollStateRef.current.scrollTop = firstElement.scrollTop;
			scrollStateRef.current.maxScroll = getMaxScroll();
		}
	}, [allElementsReady, validElements, retryCount, getMaxScroll]);

	// ==========================================================================
	// Input Handler 1: Wheel Events
	// ==========================================================================

	const handleWheel = useEffectEvent((e: WheelEvent) => {
		// Only handle vertical scrolling
		if (Math.abs(e.deltaX) > Math.abs(e.deltaY)) return;

		// #region agent log
		_dbgCounters.wheelTotal++;
		// #endregion

		const state = scrollStateRef.current;

		// Use cached maxScroll for boundary check (avoids forced layout per event).
		// maxScroll is updated by applyScrollToAll each frame and initialized on mount.
		// Guard: if maxScroll is 0 (not yet initialized), skip boundary check.
		const atTop = state.scrollTop <= 0;
		const atBottom = state.maxScroll > 0 && state.scrollTop >= state.maxScroll;
		if (e.deltaY < 0 && atTop) return; // Scrolling up at top
		if (e.deltaY > 0 && atBottom) return; // Scrolling down at bottom

		// Prevent default browser scroll
		e.preventDefault();

		// #region agent log
		_dbgCounters.wheelProcessed++;
		// #endregion

		// Apply acceleration if enabled
		const delta = effectiveEnableAcceleration
			? accelerator.getAcceleratedDelta(e.deltaY)
			: e.deltaY;

		// Accumulate delta — actual scroll applied once per frame via RAF
		pendingDeltaRef.current += delta;

		// Schedule one RAF to apply accumulated scroll (if not already scheduled)
		if (wheelRafRef.current === null) {
			wheelRafRef.current = requestAnimationFrame(() => {
				const totalDelta = pendingDeltaRef.current;
				pendingDeltaRef.current = 0;
				wheelRafRef.current = null;

				isOwnScrollRef.current = true;
				applyScrollToAll(state.scrollTop + totalDelta);
				scheduleSyncReset();

				// #region agent log
				if (_dbgCounters.wheelProcessed % 20 === 0) {
					_dbg(
						"wheel BATCH applied",
						{
							wheelTotal: _dbgCounters.wheelTotal,
							wheelProcessed: _dbgCounters.wheelProcessed,
							scrollTop: scrollStateRef.current.scrollTop,
						},
						"FIX",
					);
				}
				// #endregion
			});
		}
	});

	// ==========================================================================
	// Input Handler 2: Scrollbar Dragging (native scroll events)
	// ==========================================================================

	const handleNativeScroll = useEffectEvent((source: HTMLElement) => {
		// #region agent log
		_dbgCounters.nativeScrollTotal++;
		// #endregion

		// If our code initiated the scroll (wheel/touch/keyboard), ignore ALL native events
		if (isOwnScrollRef.current) {
			// #region agent log
			_dbgCounters.nativeScrollBlocked++;
			// #endregion
			return;
		}

		// If another panel initiated scrollbar drag, ignore this cascaded event
		if (syncSourceRef.current !== null && syncSourceRef.current !== source) {
			// #region agent log
			_dbgCounters.nativeScrollBlocked++;
			// #endregion
			return;
		}

		// #region agent log
		_dbgCounters.nativeScrollProcessed++;
		_dbg(
			"nativeScroll PROCESSED (leaked past guard)",
			{
				nativeScrollTotal: _dbgCounters.nativeScrollTotal,
				nativeScrollProcessed: _dbgCounters.nativeScrollProcessed,
				nativeScrollBlocked: _dbgCounters.nativeScrollBlocked,
				sourceScrollTop: source.scrollTop,
				stateScrollTop: scrollStateRef.current.scrollTop,
			},
			"A",
		);
		// #endregion

		// Mark this panel as the sync source (for scrollbar dragging)
		syncSourceRef.current = source;

		// The scrollbar was dragged - sync all panels to this position
		const newScrollTop = source.scrollTop;
		scrollStateRef.current.scrollTop = newScrollTop;

		// Sync to all other elements
		for (const el of validElements) {
			if (el !== source) {
				el.scrollTop = newScrollTop;
			}
		}

		// CRITICAL: Keep the guard active until next frame!
		// Scroll events from synced panels fire asynchronously.
		// If we reset immediately, those events bypass the guard → infinite loop.
		scheduleSyncReset();
	});

	// ==========================================================================
	// Input Handler 3: Keyboard Navigation (scrollToRowIndex)
	// ==========================================================================

	/**
	 * Scroll to ensure a specific row index is visible.
	 * Called by keyboard navigation when selection changes.
	 *
	 * Uses actual DOM element positions rather than calculated positions
	 * to account for MUI's internal offsets, transforms, and sub-pixel rounding.
	 */
	const scrollToRowIndex = useCallback(
		// eslint-disable-next-line @typescript-eslint/no-unused-vars
		(rowIndex: number, _totalRows: number) => {
			if (!allElementsReady || validElements.length === 0) return;

			const scroller = validElements[0]!;
			const currentScrollTop = scroller.scrollTop;

			// Try to find the actual row element in the DOM
			const rowElement = scroller.querySelector<HTMLElement>(
				`[data-rowindex="${rowIndex}"]`,
			);

			if (rowElement) {
				// Use actual DOM positions for accuracy
				const scrollerRect = scroller.getBoundingClientRect();
				const rowRect = rowElement.getBoundingClientRect();

				// In MUI X DataGrid v6+, column headers live INSIDE the virtual
				// scroller as a sticky element (.MuiDataGrid-topContainer).
				// Rows behind the sticky header are visually hidden, so the real
				// visible top is the bottom edge of that header — not scrollerRect.top.
				const topContainer = scroller.querySelector<HTMLElement>(
					".MuiDataGrid-topContainer",
				);
				const visibleTop = topContainer
					? topContainer.getBoundingClientRect().bottom
					: scrollerRect.top;

				let newScrollTop = currentScrollTop;

				// Row is above the visible area (or behind the sticky column header)
				if (rowRect.top < visibleTop) {
					newScrollTop = currentScrollTop - (visibleTop - rowRect.top);
				}
				// Row is below the viewport
				else if (rowRect.bottom > scrollerRect.bottom) {
					newScrollTop =
						currentScrollTop + (rowRect.bottom - scrollerRect.bottom);
				}

				if (newScrollTop !== currentScrollTop) {
					isOwnScrollRef.current = true;
					applyScrollToAll(newScrollTop);
					scheduleSyncReset();
				}
			} else {
				// Row is not rendered (virtualized away) — fallback to calculated position
				const viewportHeight = getViewportHeight();
				const rowTop = rowIndex * rowHeight;
				const rowBottom = rowTop + rowHeight;
				const visibleTop = currentScrollTop;
				const visibleBottom = currentScrollTop + viewportHeight;

				let newScrollTop = currentScrollTop;

				if (rowTop < visibleTop) {
					newScrollTop = rowTop;
				} else if (rowBottom >= visibleBottom) {
					newScrollTop = rowBottom - viewportHeight;
				}

				if (newScrollTop !== currentScrollTop) {
					isOwnScrollRef.current = true;
					applyScrollToAll(newScrollTop);
					scheduleSyncReset();
				}
			}
		},
		[
			allElementsReady,
			validElements,
			rowHeight,
			getViewportHeight,
			applyScrollToAll,
			scheduleSyncReset,
		],
	);

	// ==========================================================================
	// Event Listener Setup
	// ==========================================================================

	useEffect(() => {
		if (!allElementsReady) return;

		// #region agent log
		_dbgCounters.effectRuns++;
		_dbg(
			"scroll effect RUN (listener setup)",
			{
				effectRuns: _dbgCounters.effectRuns,
				validElementsCount: validElements.length,
				nativeScroll,
				wheelListenersAttached: !nativeScroll,
			},
			"D",
		);
		// #endregion

		const controller = new AbortController();
		const { signal } = controller;

		// In native scroll mode, skip wheel interception entirely.
		// The browser handles scrolling on its compositor thread (GPU-accelerated),
		// and we only sync panels via native scroll events below.
		if (!nativeScroll) {
			// Attach wheel listeners to all panels (intercept + sync mode)
			for (const el of validElements) {
				el.addEventListener("wheel", handleWheel, { passive: false, signal });
			}
		}

		// Attach native scroll listener to ALL panels
		// This catches scroll events from any source (MUI internal keyboard handling,
		// scrollbar dragging, programmatic scrolls from other code, etc.)
		// The isOwnScrollRef/syncSourceRef guards prevent infinite loops
		if (validElements.length >= 2) {
			for (const el of validElements) {
				el.addEventListener("scroll", () => handleNativeScroll(el), {
					passive: true,
					signal,
				});
			}
		}

		return () => {
			controller.abort();
			// Cancel any pending sync reset RAF
			if (syncResetRafRef.current !== null) {
				cancelAnimationFrame(syncResetRafRef.current);
				syncResetRafRef.current = null;
			}
			// Cancel any pending wheel/touch batching RAF
			if (wheelRafRef.current !== null) {
				cancelAnimationFrame(wheelRafRef.current);
				wheelRafRef.current = null;
				pendingDeltaRef.current = 0;
			}
		};
	}, [
		allElementsReady,
		validElements,
		nativeScroll,
		handleWheel,
		handleNativeScroll,
	]);

	// ==========================================================================
	// Touch Event Support (for completeness)
	// ==========================================================================

	const lastTouchYRef = useRef(0);

	const handleTouchStart = useEffectEvent((e: TouchEvent) => {
		const touch = e.touches[0];
		if (touch) {
			lastTouchYRef.current = touch.clientY;
			accelerator.reset();
		}
	});

	const handleTouchMove = useEffectEvent((e: TouchEvent) => {
		const touch = e.touches[0];
		if (!touch) return;

		const deltaY = lastTouchYRef.current - touch.clientY;
		lastTouchYRef.current = touch.clientY;

		const state = scrollStateRef.current;

		// Use cached maxScroll for boundary check (same as wheel batching)
		const atTop = state.scrollTop <= 0;
		const atBottom = state.maxScroll > 0 && state.scrollTop >= state.maxScroll;
		if (deltaY < 0 && atTop) return;
		if (deltaY > 0 && atBottom) return;

		e.preventDefault();

		const delta = effectiveEnableAcceleration
			? accelerator.getAcceleratedDelta(deltaY)
			: deltaY;

		// Accumulate delta — actual scroll applied once per frame via RAF
		pendingDeltaRef.current += delta;

		if (wheelRafRef.current === null) {
			wheelRafRef.current = requestAnimationFrame(() => {
				const totalDelta = pendingDeltaRef.current;
				pendingDeltaRef.current = 0;
				wheelRafRef.current = null;

				isOwnScrollRef.current = true;
				applyScrollToAll(state.scrollTop + totalDelta);
				scheduleSyncReset();
			});
		}
	});

	useEffect(() => {
		// In native scroll mode, browser handles touch scrolling natively
		if (!allElementsReady || nativeScroll) return;

		const controller = new AbortController();
		const { signal } = controller;

		for (const el of validElements) {
			el.addEventListener("touchstart", handleTouchStart, {
				passive: true,
				signal,
			});
			el.addEventListener("touchmove", handleTouchMove, {
				passive: false,
				signal,
			});
		}

		return () => controller.abort();
	}, [
		allElementsReady,
		nativeScroll,
		validElements,
		handleTouchStart,
		handleTouchMove,
	]);

	// ==========================================================================
	// Home/End Key Support
	// ==========================================================================

	const handleKeyDown = useEffectEvent((e: KeyboardEvent) => {
		const target = e.target as HTMLElement;
		const isInsidePanel = validElements.some((el) => el.contains(target));
		if (!isInsidePanel) return;

		if (e.key === "Home") {
			e.preventDefault();
			isOwnScrollRef.current = true;
			applyScrollToAll(0);
			scheduleSyncReset();
		} else if (e.key === "End") {
			e.preventDefault();
			isOwnScrollRef.current = true;
			applyScrollToAll(getMaxScroll());
			scheduleSyncReset();
		}
	});

	useEffect(() => {
		if (!allElementsReady) return;

		const controller = new AbortController();
		document.addEventListener("keydown", handleKeyDown, {
			signal: controller.signal,
		});
		return () => controller.abort();
	}, [allElementsReady, handleKeyDown]);

	// #region agent log
	useEffect(() => {
		let lastFrameTime = performance.now();
		let frameCount = 0;
		let minFps = Infinity;
		let lastDomCount = 0;
		const iv = setInterval(() => {
			const domCount = document.querySelectorAll("*").length;
			const heapMB = (
				performance as unknown as Record<string, Record<string, number>>
			).memory
				? Math.round(
						(performance as unknown as Record<string, Record<string, number>>)
							.memory.usedJSHeapSize /
							1024 /
							1024,
					)
				: -1;
			_dbg(
				"PERIODIC COUNTERS",
				{
					..._dbgCounters,
					domCount,
					domDelta: domCount - lastDomCount,
					heapMB,
					minFps: minFps === Infinity ? -1 : Math.round(minFps),
					frameCount,
				},
				"ALL,F,H",
			);
			lastDomCount = domCount;
			minFps = Infinity;
			frameCount = 0;
		}, 3000);
		let rafId: number;
		const measureFps = () => {
			const now = performance.now();
			const delta = now - lastFrameTime;
			if (delta > 0) {
				const fps = 1000 / delta;
				if (fps < minFps) minFps = fps;
				frameCount++;
			}
			lastFrameTime = now;
			rafId = requestAnimationFrame(measureFps);
		};
		rafId = requestAnimationFrame(measureFps);
		return () => {
			clearInterval(iv);
			cancelAnimationFrame(rafId);
		};
	}, []);
	// #endregion

	return {
		scrollToRowIndex,
		scrollTop: scrollStateRef.current.scrollTop,
	};
}
