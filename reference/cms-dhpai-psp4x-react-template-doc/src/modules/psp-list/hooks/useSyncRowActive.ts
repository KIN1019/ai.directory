import { useEffect, useRef } from "react";

/**
 * CSS class applied to rows that match the synchronized active (pressed) state
 */
export const PSP_ROW_ACTIVE_CLASS = "psp-row-active";

/** Selector for MUI DataGrid row elements */
const ROW_SELECTOR = ".MuiDataGrid-row";

export interface UseSyncRowActiveOptions {
	/** Container ref that wraps all DataGrid panels */
	containerRef: React.RefObject<HTMLDivElement | null>;
}

/**
 * Hook to synchronize row active/pressed state across multiple DataGrid panels
 * using direct DOM manipulation for zero-delay visual feedback.
 *
 * When a user presses down on a row in any panel, the same row in all other panels
 * will immediately be highlighted with the active class - no React re-render needed.
 *
 * @example
 * ```tsx
 * const containerRef = useRef<HTMLDivElement>(null);
 * useSyncRowActive({ containerRef });
 *
 * return (
 *   <Box ref={containerRef}>
 *     <DataGridPro ... />
 *     <DataGridPro ... />
 *   </Box>
 * );
 * ```
 */
export function useSyncRowActive({
	containerRef,
}: UseSyncRowActiveOptions): void {
	// Track currently active rows for efficient cleanup
	const activeRowsRef = useRef<Element[]>([]);

	useEffect(() => {
		const container = containerRef.current;
		if (!container) return;

		/**
		 * Clear active class from all active rows
		 */
		const clearActive = () => {
			for (const row of activeRowsRef.current) {
				row.classList.remove(PSP_ROW_ACTIVE_CLASS);
			}
			activeRowsRef.current = [];
		};

		/**
		 * Handle mousedown on row elements - add active class to all matching rows
		 */
		const handleMouseDown = (event: MouseEvent) => {
			const target = event.target as Element;
			const row = target.closest(ROW_SELECTOR);

			if (!row) return;

			const rowId = row.getAttribute("data-id");
			if (rowId === null) return;

			// Find all rows with matching data-id across all panels and add active class
			const matchingRows = container.querySelectorAll(
				`${ROW_SELECTOR}[data-id="${CSS.escape(rowId)}"]`,
			);

			matchingRows.forEach((matchingRow) => {
				matchingRow.classList.add(PSP_ROW_ACTIVE_CLASS);
			});

			activeRowsRef.current = Array.from(matchingRows);
		};

		/**
		 * Handle mouseup - clear active state
		 */
		const handleMouseUp = () => {
			clearActive();
		};

		const controller = new AbortController();
		const { signal } = controller;

		// Listen for mousedown to add active state
		container.addEventListener("mousedown", handleMouseDown, { signal });
		// Listen for mouseup on document to clear active state (even if released outside)
		document.addEventListener("mouseup", handleMouseUp, { signal });

		return () => {
			controller.abort();
			clearActive();
		};
	}, [containerRef]);
}
