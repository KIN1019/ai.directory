import { useEffect, useCallback } from "react";
import type {
	GridRowSelectionModel,
	GridValidRowModel,
	GridRowId,
} from "@mui/x-data-grid-pro";
import { useEffectEvent } from "./useEffectEvent";

export interface UseKeyboardRowNavigationOptions {
	/** The current sorted rows */
	sortedRows: readonly GridValidRowModel[];
	/** The current row selection model */
	rowSelectionModel: GridRowSelectionModel;
	/** Callback to update row selection */
	onRowSelectionModelChange: (model: GridRowSelectionModel) => void;
	/** Callback when Enter key is pressed on selected row */
	onRowConfirm?: (rowId: GridRowId) => void;
	/** Container element to listen for keyboard events (null if not ready) */
	containerElement: HTMLElement | null;
	/** Whether to enable keyboard navigation. Default: true */
	enabled?: boolean;
	/**
	 * External scroll function provided by scroll coordinator.
	 * When provided, keyboard navigation will use this to scroll all panels in sync.
	 * When not provided, no scrolling occurs (selection only).
	 */
	scrollToRowIndex?: (rowIndex: number, totalRows: number) => void;
}

/**
 * Hook that handles keyboard navigation for DataGrid row selection.
 * - ArrowUp/ArrowDown: Move selection to previous/next row
 * - Enter: Confirm the selected row
 *
 * Uses external scrollToRowIndex function for synchronized scrolling across panels.
 */
export function useKeyboardRowNavigation({
	sortedRows,
	rowSelectionModel,
	onRowSelectionModelChange,
	onRowConfirm,
	containerElement,
	enabled = true,
	scrollToRowIndex,
}: UseKeyboardRowNavigationOptions): void {
	// Get the currently selected row ID (single selection mode).
	// MUI X Data Grid: rowSelectionModel is readonly GridRowId[] (array of selected ids)
	const getSelectedRowId = useCallback((): GridRowId | null => {
		if (!Array.isArray(rowSelectionModel) || rowSelectionModel.length === 0)
			return null;
		return rowSelectionModel[0] ?? null;
	}, [rowSelectionModel]);

	// Find the index of a row by its ID
	const getRowIndex = useCallback(
		(rowId: GridRowId): number => {
			return sortedRows.findIndex((row) => row.id === rowId);
		},
		[sortedRows],
	);

	// Stable event handlers using useEffectEvent
	const handleSelectionChange = useEffectEvent(
		(newSelection: GridRowSelectionModel) => {
			onRowSelectionModelChange(newSelection);
		},
	);

	const handleConfirm = useEffectEvent((rowId: GridRowId) => {
		onRowConfirm?.(rowId);
	});

	// Stable scroll handler
	const handleScrollToRow = useEffectEvent((rowIndex: number) => {
		scrollToRowIndex?.(rowIndex, sortedRows.length);
	});

	useEffect(() => {
		if (!enabled || !containerElement) return;

		const handleKeyDown = (e: KeyboardEvent) => {
			// Only handle if focus is inside our container
			const target = e.target as HTMLElement;
			if (!containerElement.contains(target)) return;

			const selectedId = getSelectedRowId();
			const currentIndex = selectedId !== null ? getRowIndex(selectedId) : -1;

			switch (e.key) {
				case "ArrowDown": {
					// Stop propagation BEFORE MUI sees it (we're in capture phase).
					// This prevents MUI from scrolling only the focused panel.
					e.preventDefault();
					e.stopPropagation();
					const nextIndex =
						currentIndex === -1
							? 0
							: Math.min(currentIndex + 1, sortedRows.length - 1);
					const nextRow = sortedRows[nextIndex];
					if (nextRow) {
						const newId = nextRow.id as GridRowId;
						handleSelectionChange([newId]);
						handleScrollToRow(nextIndex);
					}
					break;
				}
				case "ArrowUp": {
					e.preventDefault();
					e.stopPropagation();
					const prevIndex =
						currentIndex === -1
							? sortedRows.length - 1
							: Math.max(currentIndex - 1, 0);
					const prevRow = sortedRows[prevIndex];
					if (prevRow) {
						const newId = prevRow.id as GridRowId;
						handleSelectionChange([newId]);
						handleScrollToRow(prevIndex);
					}
					break;
				}
				case "Enter": {
					if (selectedId !== null) {
						e.preventDefault();
						handleConfirm(selectedId);
					}
					break;
				}
			}
		};

		// Use CAPTURE phase so our handler fires BEFORE MUI's internal handlers.
		// This lets us stopPropagation() to prevent MUI from doing its own
		// single-panel scrolling, which would conflict with our synced scrolling.
		containerElement.addEventListener("keydown", handleKeyDown, true);
		return () =>
			containerElement.removeEventListener("keydown", handleKeyDown, true);
		// Stable handlers from useEffectEvent don't need to be in deps
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, [enabled, containerElement, sortedRows, getSelectedRowId, getRowIndex]);
}
