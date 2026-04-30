/**
 * Re-export grid types from their canonical location for backward compatibility.
 * New code should import directly from "../types" instead.
 */
export type {
	RowConfirmHandler,
	SplitPanelConfig,
	GridCallbackDetails,
	ManagedProps,
	DataGridSplitProps,
	ResolvedPanel,
	ContextMenuItem,
	ContextMenuConfig,
} from "../types";

export {
	DEFAULT_PANEL_WIDTH,
	DEFAULT_MIN_WIDTH,
	LAST_PANEL_MIN_WIDTH,
} from "../types";
