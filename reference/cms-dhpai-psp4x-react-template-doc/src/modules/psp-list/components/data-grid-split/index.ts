/**
 * DataGridSplit - A split-panel DataGrid implementation with synchronized scrolling.
 *
 * This module provides components for creating horizontally scrollable
 * split panels with synchronized vertical scrolling.
 */

// Main public API
export { DataGridSplit } from "./DataGridSplit";

// Sort icons for customization
export {
	SortIcon,
	SortIconAsc,
	SortIconDesc,
	SortIconUnsorted,
} from "./SortIcon";

// Lock icons for row/header indicators
export { LockIcon, LockIconCell, LockHeaderIcon } from "./LockIcon";

// Note: GridContextMenu is internal to SplitPanelRenderer and not exported.
// Use `contextMenuConfig` prop on DataGridSplit to customize context menu items.
