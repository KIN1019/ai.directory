import { useState, useCallback } from "react";
import type {
	GridRowSelectionModel,
	GridRowId,
	GridApi,
} from "@mui/x-data-grid-pro";
import type { GridCallbackDetails } from "../types";

/** MUI X Data Grid row selection model: readonly GridRowId[] (array of selected row ids) */
const EMPTY_SELECTION: GridRowSelectionModel = [] as GridRowSelectionModel;

function normalizeToSelectionModel(
	value: GridRowSelectionModel | GridRowId | undefined,
): GridRowSelectionModel {
	if (value == null) return EMPTY_SELECTION;
	if (Array.isArray(value)) return [...value] as GridRowSelectionModel;
	// Single id (GridInputRowSelectionModel allows GridRowId)
	return [value] as GridRowSelectionModel;
}

interface UseRowSelectionResult {
	/** Current row selection model (controlled or internal) */
	rowSelectionModel: GridRowSelectionModel;
	/** Handler for row selection changes */
	handleRowSelectionModelChange: (
		newSelectionModel: GridRowSelectionModel,
	) => void;
}

/**
 * Hook to manage row selection state with controlled/uncontrolled pattern.
 *
 * Handles:
 * - Internal state for uncontrolled mode (array of selected row ids)
 * - Callback forwarding for controlled mode
 *
 * @param controlledRowSelectionModel - External selection model (controlled mode)
 * @param onRowSelectionModelChange - External change handler (controlled mode)
 * @param primaryApiRef - API ref for callback details
 * @returns Row selection state and handlers
 */
export function useRowSelection(
	controlledRowSelectionModel: GridRowSelectionModel | undefined,
	onRowSelectionModelChange:
		| ((model: GridRowSelectionModel, details: GridCallbackDetails) => void)
		| undefined,
	primaryApiRef: React.MutableRefObject<GridApi>,
): UseRowSelectionResult {
	const [internalRowSelectionModel, setInternalRowSelectionModel] =
		useState<GridRowSelectionModel>(() => EMPTY_SELECTION);

	const rowSelectionModel =
		controlledRowSelectionModel ?? internalRowSelectionModel;

	const handleRowSelectionModelChange = useCallback(
		(newSelectionModel: GridRowSelectionModel) => {
			if (onRowSelectionModelChange) {
				onRowSelectionModelChange(newSelectionModel, {
					reason: undefined,
					api: primaryApiRef.current,
				});
			} else {
				const normalized = normalizeToSelectionModel(newSelectionModel);
				setInternalRowSelectionModel(normalized);
			}
		},
		[onRowSelectionModelChange, primaryApiRef],
	);

	return { rowSelectionModel, handleRowSelectionModelChange };
}
