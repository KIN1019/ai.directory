import { useState, useCallback, useRef, useMemo } from "react";
import type {
	GridColDef,
	GridSortModel,
	GridRowSelectionModel,
	GridValidRowModel,
	GridApi,
} from "@mui/x-data-grid-pro";
import type {
	SplitPanelConfig,
	GridCallbackDetails,
	ResolvedPanel,
	ContextMenuConfig,
	ContextMenuItem,
} from "../types";
import { useContextMenu, type ContextMenuPosition } from "./useContextMenu";
import { useResolvedPanels } from "./useResolvedPanels";
import { useApiRefs } from "./useApiRefs";
import { usePanelWidths } from "./usePanelWidths";
import { useSortModel } from "./useSortModel";
import { useRowSelection } from "./useRowSelection";

export interface UseSplitPanelStateOptions {
	/** Column definitions */
	columns: readonly GridColDef[];
	/** Row data */
	rows: readonly GridValidRowModel[];
	/** Panel configurations */
	panelConfigs: SplitPanelConfig[];
	/** Controlled sort model */
	controlledSortModel?: GridSortModel;
	/** Sort model change handler */
	onSortModelChange?: (
		model: GridSortModel,
		details: GridCallbackDetails,
	) => void;
	/** Controlled row selection */
	controlledRowSelectionModel?: GridRowSelectionModel;
	/** Row selection change handler */
	onRowSelectionModelChange?: (
		model: GridRowSelectionModel,
		details: GridCallbackDetails,
	) => void;
	/** Context menu configuration (optional) */
	contextMenuConfig?: ContextMenuConfig;
}

export interface UseSplitPanelStateResult {
	/** Ref for the container element */
	containerRef: React.RefObject<HTMLDivElement | null>;

	// Context menu
	/** Current context menu position, or null if closed */
	contextMenuPosition: ContextMenuPosition | null;
	/** Handler for right-click events */
	handleContextMenu: (event: React.MouseEvent<HTMLElement>) => void;
	/** Close the context menu */
	handleCloseContextMenu: () => void;

	// Context menu item selection
	/** Menu items for the context menu */
	menuItems: readonly ContextMenuItem[];
	/** Currently selected item ID */
	selectedItemId: string | null;
	/** Handler for menu item selection */
	handleMenuItemSelect: (item: ContextMenuItem) => void;

	// Panel configuration
	/** Resolved panel configurations with computed columns */
	resolvedPanels: ResolvedPanel[];
	/** API refs for all panels */
	apiRefs: React.MutableRefObject<GridApi>[];
	/** Primary API ref (first panel) */
	primaryApiRef: React.MutableRefObject<GridApi>;
	/** Current widths for each panel */
	panelWidths: number[];
	/** Creates a drag handler for a specific panel divider */
	createDividerDragHandler: (panelIndex: number) => (deltaX: number) => void;

	// Sort model
	/** Current sort model */
	sortModel: GridSortModel;
	/** Sorted rows */
	sortedRows: readonly GridValidRowModel[];
	/** Handler for sort model changes */
	handleSortModelChange: (model: GridSortModel) => void;

	// Row selection
	/** Current row selection model */
	rowSelectionModel: GridRowSelectionModel;
	/** Handler for row selection changes */
	handleRowSelectionModelChange: (model: GridRowSelectionModel) => void;
}

/**
 * Composite hook that manages all state for the SplitPanelRenderer component.
 *
 * This hook consolidates:
 * - Context menu state
 * - Generic menu item selection (controlled/uncontrolled)
 * - Panel resolution and widths
 * - API refs for multi-grid synchronization
 * - Sort model (controlled/uncontrolled)
 * - Row selection (controlled/uncontrolled)
 *
 * @param options - Configuration options
 * @returns All state and handlers needed for split panel rendering
 */
export function useSplitPanelState(
	options: UseSplitPanelStateOptions,
): UseSplitPanelStateResult {
	const {
		columns,
		rows,
		panelConfigs,
		controlledSortModel,
		onSortModelChange,
		controlledRowSelectionModel,
		onRowSelectionModelChange,
		contextMenuConfig,
	} = options;

	// Container ref for width calculations
	const containerRef = useRef<HTMLDivElement>(null);

	// Context menu state
	const { contextMenuPosition, handleContextMenu, handleCloseContextMenu } =
		useContextMenu();

	// Extract menu items from config (memoized for stable reference)
	const menuItems = useMemo(
		() => contextMenuConfig?.items ?? [],
		[contextMenuConfig?.items],
	);

	// Internal selected item state if not controlled
	const [internalSelectedId, setInternalSelectedId] = useState<string | null>(
		null,
	);
	const selectedItemId = contextMenuConfig?.selectedId ?? internalSelectedId;

	const handleMenuItemSelect = useCallback(
		(item: ContextMenuItem) => {
			if (contextMenuConfig?.onSelect) {
				contextMenuConfig.onSelect(item);
			} else {
				setInternalSelectedId(item.id);
			}
		},
		[contextMenuConfig],
	);

	// Resolve panel configurations: compute columns for each panel
	const resolvedPanels = useResolvedPanels(columns, panelConfigs);

	// Create API refs for all panels
	const apiRefs = useApiRefs(resolvedPanels.length);

	// First panel's API ref used for callbacks (MUI requirement for primary grid ref)
	// Non-null assertion is safe: resolvedPanels always has at least 1 panel (the "remaining" panel)
	const primaryApiRef = apiRefs[0]!;

	// Panel width state and drag handlers
	const { panelWidths, createDividerDragHandler } = usePanelWidths(
		resolvedPanels,
		containerRef,
	);

	// Sort model state (controlled/uncontrolled)
	const { sortModel, sortedRows, handleSortModelChange } = useSortModel(
		rows,
		columns,
		controlledSortModel,
		onSortModelChange,
		primaryApiRef,
	);

	// Row selection state (controlled/uncontrolled)
	const { rowSelectionModel, handleRowSelectionModelChange } = useRowSelection(
		controlledRowSelectionModel,
		onRowSelectionModelChange,
		primaryApiRef,
	);

	return {
		containerRef,

		// Context menu
		contextMenuPosition,
		handleContextMenu,
		handleCloseContextMenu,

		// Context menu item selection
		menuItems,
		selectedItemId,
		handleMenuItemSelect,

		// Panel configuration
		resolvedPanels,
		apiRefs,
		primaryApiRef,
		panelWidths,
		createDividerDragHandler,

		// Sort model
		sortModel,
		sortedRows,
		handleSortModelChange,

		// Row selection
		rowSelectionModel,
		handleRowSelectionModelChange,
	};
}
