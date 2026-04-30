import { useState, useMemo, useCallback } from "react";
import type {
	GridColDef,
	GridSortModel,
	GridValidRowModel,
	GridApi,
} from "@mui/x-data-grid-pro";
import { sortRows, type ColumnSortConfig } from "../utils/sortRows";
import type { GridCallbackDetails } from "../types";

/**
 * Convert MUI GridColDef columns to generic ColumnSortConfig.
 * Only includes columns that have a sortComparator defined.
 */
function toColumnSortConfigs(
	columns: readonly GridColDef[],
): ColumnSortConfig[] {
	return columns
		.filter((col) => col.sortComparator != null)
		.map((col) => ({
			field: col.field,
			sortComparator: (valueA, valueB, rowRefA, rowRefB) =>
				col.sortComparator!(
					valueA,
					valueB,
					{
						id: rowRefA.id,
					} as Parameters<NonNullable<GridColDef["sortComparator"]>>[2],
					{
						id: rowRefB.id,
					} as Parameters<NonNullable<GridColDef["sortComparator"]>>[3],
				),
		}));
}

interface UseSortModelResult {
	/** Current sort model (controlled or internal) */
	sortModel: GridSortModel;
	/** Sorted rows based on current sort model */
	sortedRows: readonly GridValidRowModel[];
	/** Handler for sort model changes */
	handleSortModelChange: (newSortModel: GridSortModel) => void;
}

/**
 * Hook to manage sort model state with controlled/uncontrolled pattern.
 *
 * Handles:
 * - Internal state for uncontrolled mode
 * - Callback forwarding for controlled mode
 * - Row sorting based on current sort model
 *
 * @param rows - Row data to sort
 * @param columns - Column definitions (for sort comparators)
 * @param controlledSortModel - External sort model (controlled mode)
 * @param onSortModelChange - External change handler (controlled mode)
 * @param primaryApiRef - API ref for callback details
 * @returns Sort model state and handlers
 */
export function useSortModel(
	rows: readonly GridValidRowModel[],
	columns: readonly GridColDef[],
	controlledSortModel: GridSortModel | undefined,
	onSortModelChange:
		| ((model: GridSortModel, details: GridCallbackDetails) => void)
		| undefined,
	primaryApiRef: React.MutableRefObject<GridApi>,
): UseSortModelResult {
	// Internal sort model state (for uncontrolled mode)
	const [internalSortModel, setInternalSortModel] = useState<GridSortModel>([]);
	const sortModel = controlledSortModel ?? internalSortModel;

	// Convert MUI columns to generic sort configs (memoized)
	const columnSortConfigs = useMemo(
		() => toColumnSortConfigs(columns),
		[columns],
	);

	// Sort rows at the parent level so all grids show the same order
	const sortedRows = useMemo(() => {
		if (!rows || sortModel.length === 0) {
			return rows;
		}
		return sortRows(rows as GridValidRowModel[], sortModel, {
			columns: columnSortConfigs,
		});
	}, [rows, sortModel, columnSortConfigs]);

	// Handle sort model change - sync across all grids
	const handleSortModelChange = useCallback(
		(newSortModel: GridSortModel) => {
			if (onSortModelChange) {
				onSortModelChange(newSortModel, {
					reason: undefined,
					api: primaryApiRef.current,
				});
			} else {
				setInternalSortModel(newSortModel);
			}
		},
		[onSortModelChange, primaryApiRef],
	);

	return { sortModel, sortedRows, handleSortModelChange };
}
