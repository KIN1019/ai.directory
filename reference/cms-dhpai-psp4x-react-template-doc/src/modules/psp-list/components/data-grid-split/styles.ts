import type { SxProps, Theme } from "@mui/material";
import { pspColors } from "../../theme/pspTheme";

/** Styles applied to all grid panels */
export const GRID_COMMON_SX: SxProps<Theme> = {
	// Hide empty filler cells
	"& .MuiDataGrid-cellEmpty": { display: "none !important" },
	// Hide filler elements
	"& .MuiDataGrid-filler": { display: "none !important" },
	// Hide scrollbar filler in header
	"& .MuiDataGrid-scrollbarFiller": { display: "none !important" },
	"& .MuiDataGrid-columnHeader": {
		borderRadius: "0 !important",
	},
	// Force horizontal scrollbar to always show on all panels
	// This ensures consistent viewport heights for scroll sync calculations
	"& .MuiDataGrid-scrollbar--horizontal": {
		display: "block !important",
	},
};

/** Stretch last cell/header to fill remaining width (last panel only) */
export const GRID_FLEX_LAST_COLUMN_SX: SxProps<Theme> = {
	"& .MuiDataGrid-cell:has(+ .MuiDataGrid-cellEmpty), & .MuiDataGrid-columnHeader--last":
		{ flex: "1 !important" },
};

/** Styles to hide vertical scrollbar (applied to non-last panels) */
export const GRID_HIDE_SCROLLBAR_SX: SxProps<Theme> = {
	// Hide MUI's vertical scrollbar element (we sync vertical scroll via the last panel)
	"& .MuiDataGrid-scrollShadow": { border: "none !important" },
	"& .MuiDataGrid-scrollbar--vertical": { display: "none !important" },
	// Hide native vertical scrollbar in webkit browsers (width: 0 hides vertical only, keeps horizontal)
	"& .MuiDataGrid-virtualScroller::-webkit-scrollbar": { width: 0 },
};

/** Base panel container styles */
const PANEL_BASE_SX = {
	overflow: "hidden",
	contain: "strict",
	backgroundColor: pspColors.outerBackground,
} as const;

/** Get panel container styles based on position */
export function getPanelContainerSx(
	isLast: boolean,
	minWidth: number,
	width?: number,
): SxProps<Theme> {
	return isLast
		? { ...PANEL_BASE_SX, flex: 1, minWidth }
		: { ...PANEL_BASE_SX, width, minWidth, flexShrink: 0 };
}

/** Get grid border styles based on panel position */
export function getGridBorderSx(
	isFirst: boolean,
	isLast: boolean,
): SxProps<Theme> {
	return {
		// No border radius anywhere
		borderRadius: 0,
		"& .MuiDataGrid-columnHeaders": {
			borderRadius: 0,
			...(!isFirst && { borderLeft: "none" }),
			...(!isLast && { borderRight: "none" }),
		},
		// Border edges
		...(!isFirst && { borderLeft: "none" }),
		...(!isLast && { borderRight: "none" }),
	};
}
