import { useEffect, useRef } from "react";

// #region agent log
const _DBG_ENDPOINT =
	"http://127.0.0.1:7242/ingest/14ec58d7-a42d-48a0-b5df-766ce3885083";
let _hoverCount = 0;
// #endregion

/**
 * CSS class applied to rows that match the synchronized hover state
 */
export const PSP_ROW_HOVER_CLASS = "psp-row-hover";

/** Selector for MUI DataGrid row elements */
const ROW_SELECTOR = ".MuiDataGrid-row";

export interface UseSyncRowHoverOptions {
	/** Container ref that wraps all DataGrid panels */
	containerRef: React.RefObject<HTMLDivElement | null>;
}

/**
 * Hook to synchronize row hover state across multiple DataGrid panels
 * using direct DOM manipulation for zero-delay highlighting.
 *
 * When a user hovers over a row in any panel, the same row in all other panels
 * will immediately be highlighted with the hover class - no React re-render needed.
 *
 * @example
 * ```tsx
 * const containerRef = useRef<HTMLDivElement>(null);
 * useSyncRowHover({ containerRef });
 *
 * return (
 *   <Box ref={containerRef}>
 *     <DataGridPro ... />
 *     <DataGridPro ... />
 *   </Box>
 * );
 * ```
 */
export function useSyncRowHover({
	containerRef,
}: UseSyncRowHoverOptions): void {
	// Track previously hovered rows for efficient cleanup
	const previousHoveredRowsRef = useRef<Element[]>([]);

	useEffect(() => {
		const container = containerRef.current;
		if (!container) return;

		/**
		 * Clear hover class from all previously hovered rows
		 */
		const clearHover = () => {
			for (const row of previousHoveredRowsRef.current) {
				row.classList.remove(PSP_ROW_HOVER_CLASS);
			}
			previousHoveredRowsRef.current = [];
		};

		/**
		 * Handle mouseenter on row elements - add hover class to all matching rows
		 */
		const handleMouseOver = (event: MouseEvent) => {
			const target = event.target as Element;
			const row = target.closest(ROW_SELECTOR);

			if (!row) return;

			const rowId = row.getAttribute("data-id");
			if (rowId === null) return;

			// #region agent log
			_hoverCount++;
			if (_hoverCount % 50 === 0) {
				fetch(_DBG_ENDPOINT, {
					method: "POST",
					headers: { "Content-Type": "application/json" },
					body: JSON.stringify({
						location: "useSyncRowHover.ts",
						message: "mouseover (every 50th)",
						data: { hoverCount: _hoverCount },
						timestamp: Date.now(),
						sessionId: "debug-session",
						hypothesisId: "G",
					}),
				}).catch(() => {});
			}
			// #endregion

			// Clear previous hover state
			clearHover();

			// Find all rows with matching data-id across all panels and add hover class
			const matchingRows = container.querySelectorAll(
				`${ROW_SELECTOR}[data-id="${CSS.escape(rowId)}"]`,
			);

			matchingRows.forEach((matchingRow) => {
				matchingRow.classList.add(PSP_ROW_HOVER_CLASS);
			});

			previousHoveredRowsRef.current = Array.from(matchingRows);
		};

		/**
		 * Handle mouseleave from the container - clear all hover states
		 */
		const handleMouseLeave = (event: MouseEvent) => {
			// Only clear if actually leaving the container (not entering a child)
			const relatedTarget = event.relatedTarget as Element | null;
			if (relatedTarget && container.contains(relatedTarget)) return;

			clearHover();
		};

		const controller = new AbortController();
		const { signal } = controller;

		// Use mouseover (bubbles) instead of mouseenter for event delegation
		container.addEventListener("mouseover", handleMouseOver, { signal });
		container.addEventListener("mouseleave", handleMouseLeave, { signal });

		return () => {
			controller.abort();
			clearHover();
		};
	}, [containerRef]);
}
