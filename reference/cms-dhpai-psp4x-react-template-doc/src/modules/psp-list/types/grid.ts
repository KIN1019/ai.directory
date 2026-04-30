import type {
	GridColDef,
	GridValidRowModel,
	GridSortModel,
	GridRowSelectionModel,
	GridRowId,
} from "@mui/x-data-grid-pro";
import type { SxProps, Theme } from "@mui/material";

/**
 * Handler for row confirmation (Enter key or double-click)
 */
export type RowConfirmHandler = (rowId: GridRowId) => void;

/**
 * A single item in the context menu.
 * Generic interface that allows users to define custom menu items.
 */
export interface ContextMenuItem {
	/** Unique identifier for the item (used for selection tracking) */
	id: string;
	/** Display label for the menu item */
	label: string;
}

/**
 * Configuration for the context menu section.
 * Allows users to provide custom items and selection handling.
 */
export interface ContextMenuConfig<
	T extends ContextMenuItem = ContextMenuItem,
> {
	/** Array of menu items to display */
	items: readonly T[];
	/** Currently selected item ID (controlled) */
	selectedId?: string | null;
	/** Callback when an item is selected */
	onSelect?: (item: T) => void;
}

/**
 * Configuration for a split panel
 */
export interface SplitPanelConfig {
	/** Column fields for this panel */
	fields: string[];
	/** Initial width of the panel in pixels (defaults to DEFAULT_PANEL_WIDTH) */
	initialWidth?: number;
	/** Minimum width of the panel in pixels (defaults to DEFAULT_MIN_WIDTH) */
	minWidth?: number;
}

/**
 * Common DataGrid callback details shape.
 * Uses `unknown` for api since MUI's GridApi type varies.
 */
export interface GridCallbackDetails {
	reason: undefined;
	api: { current: unknown } | unknown;
}

/**
 * Props managed by DataGridSplit (excluded from passthrough to individual grids)
 */
export type ManagedProps =
	| "columns"
	| "rows"
	| "sortModel"
	| "onSortModelChange"
	| "rowSelectionModel"
	| "onRowSelectionModelChange"
	| "initialState"
	| "gridComponent"
	| "splitPanels";

/**
 * DataGridSplit props with generic grid component support.
 *
 * @typeParam TProps - Inferred from gridComponent (DataGridProps)
 */
export type DataGridSplitProps<TProps> = Omit<TProps, ManagedProps> & {
	/** The grid component to render - REQUIRED */
	gridComponent: React.ComponentType<TProps>;

	/** Row data */
	rows: readonly GridValidRowModel[];

	/** Column definitions */
	columns: readonly GridColDef[];

	/**
	 * Split panel configuration. Each panel (except the last) contains the specified
	 * columns, and the final panel automatically contains all remaining columns.
	 *
	 * If not provided, renders a single grid with all columns.
	 *
	 * @example
	 * ```tsx
	 * splitPanels={[
	 *   { fields: ['id', 'name'], initialWidth: 250, minWidth: 150 },
	 *   { fields: ['category', 'status'], initialWidth: 300 },
	 *   // Remaining columns go to the last (auto-created) panel
	 * ]}
	 * ```
	 */
	splitPanels?: SplitPanelConfig[];

	/** Initial state for the grid */
	initialState?: Record<string, unknown>;

	/** Controlled sort model */
	sortModel?: GridSortModel;

	/** Sort model change handler */
	onSortModelChange?: (
		model: GridSortModel,
		details: GridCallbackDetails,
	) => void;

	/** Controlled row selection */
	rowSelectionModel?: GridRowSelectionModel;

	/** Row selection change handler */
	onRowSelectionModelChange?: (
		model: GridRowSelectionModel,
		details: GridCallbackDetails,
	) => void;

	/** Row height in pixels */
	rowHeight?: number;

	/** Column header height in pixels */
	columnHeaderHeight?: number;

	/** Slot overrides */
	slots?: Record<string, unknown>;

	/** Slot props */
	slotProps?: Record<string, unknown>;

	/** Whether to show checkboxes for row selection */
	checkboxSelection?: boolean;

	/** Whether to disable the column menu */
	disableColumnMenu?: boolean;

	/** MUI System sx prop */
	sx?: SxProps<Theme>;

	/** Callback when a row is confirmed (Enter key or double-click) */
	onRowConfirm?: RowConfirmHandler;

	/**
	 * Configuration for the context menu items section.
	 * Allows custom menu items with selection handling.
	 *
	 * @example
	 * ```tsx
	 * contextMenuConfig={{
	 *   items: [
	 *     { id: 'hospital-1', label: 'Queen Mary Hospital' },
	 *     { id: 'hospital-2', label: 'Queen Elizabeth Hospital' },
	 *   ],
	 *   selectedId: 'hospital-1',
	 *   onSelect: (item) => console.log('Selected:', item.id),
	 * }}
	 * ```
	 */
	contextMenuConfig?: ContextMenuConfig;
};

/**
 * Resolved panel configuration with computed columns
 */
export interface ResolvedPanel {
	columns: GridColDef[];
	initialWidth: number;
	minWidth: number;
	isLast: boolean;
}

// Default panel configuration constants
export const DEFAULT_PANEL_WIDTH = 300;
export const DEFAULT_MIN_WIDTH = 150;
export const LAST_PANEL_MIN_WIDTH = 200;
