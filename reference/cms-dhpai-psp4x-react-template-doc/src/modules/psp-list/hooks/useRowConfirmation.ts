import { useCallback } from "react";
import type { GridRowId } from "@mui/x-data-grid-pro";

export interface RowConfirmationHandler {
	(rowId: GridRowId): void;
}

export interface UseRowConfirmationOptions {
	/** Custom confirmation handler. If not provided, uses default console.log placeholder. */
	onConfirm?: RowConfirmationHandler;
}

export interface UseRowConfirmationResult {
	/** Function to call when a row is confirmed (Enter key or double-click) */
	confirmRow: RowConfirmationHandler;
}

/**
 * Hook that provides a pluggable row confirmation mechanism.
 *
 * Currently a placeholder that logs to console. Designed for easy swap to:
 * - window.postMessage for cross-frame communication
 * - Custom callback for parent component handling
 * - Navigation or state updates
 *
 * @example
 * // Basic usage with default placeholder
 * const { confirmRow } = useRowConfirmation();
 *
 * @example
 * // With custom handler
 * const { confirmRow } = useRowConfirmation({
 *   onConfirm: (rowId) => {
 *     window.postMessage({ type: 'ROW_SELECTED', rowId }, '*');
 *   },
 * });
 */
export function useRowConfirmation({
	onConfirm,
}: UseRowConfirmationOptions = {}): UseRowConfirmationResult {
	const confirmRow = useCallback(
		(rowId: GridRowId) => {
			if (onConfirm) {
				onConfirm(rowId);
			} else {
				// Default placeholder - replace with actual implementation
				console.log("[useRowConfirmation] Row confirmed:", rowId);
			}
		},
		[onConfirm],
	);

	return { confirmRow };
}
