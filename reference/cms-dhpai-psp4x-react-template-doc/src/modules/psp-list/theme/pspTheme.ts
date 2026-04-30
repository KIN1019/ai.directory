import { createTheme } from "@mui/material/styles";
import type {} from "@mui/x-data-grid/themeAugmentation";

/**
 * PSP Data Grid color palette (ExtJS Migration specs)
 */
export const pspColors = {
	// Typography
	fontFamily: "Arial, sans-serif",
	fontSize: "14px",
	lineHeight: "120%",

	// Header
	headerBackground: "#ececec",
	headerText: "#790000",

	// Cells
	cellText: "#000079",
	cellTextHighlight: "#f43440",
	cellBackgroundOdd: "#d2d2d2",
	cellBackgroundEven: "#c6c6c6",
	cellBackgroundHover: "#b8b8b8",
	cellBackgroundActive: "#0401bc",

	// Borders
	tableBorder: "#c0c0c0",
	outerBackground: "#d1d1d1",

	// Icons
	lockIcon: "#9c1407",
	lockIconHeader: "#828282",

	// Toolbar
	toolbarBackground: "#ececec",
	toolbarLabelText: "#3c3c3c",
	toolbarStatLabelText: "#1c1c1c",
	toolbarStatValueBackground: "#ECECEC",
	toolbarStatValueBorder: "#a0a0a0",
	toolbarStatValueText: "#000000",
	selectBackground: "#ffffff",
	selectBorder: "#c3c3c3",
	selectText: "#000000",
} as const;

/**
 * MUI theme with PSP Data Grid colors (ExtJS Migration)
 */
export const pspTheme = createTheme({
	typography: {
		fontFamily: pspColors.fontFamily,
		fontSize: 14,
	},
	palette: {
		primary: {
			main: pspColors.headerText,
		},
		secondary: {
			main: pspColors.cellTextHighlight,
		},
		background: {
			default: pspColors.outerBackground,
			paper: pspColors.cellBackgroundOdd,
		},
		text: {
			primary: pspColors.cellText,
			secondary: pspColors.headerText,
		},
	},
	components: {
		MuiCssBaseline: {
			styleOverrides: {
				body: {
					backgroundColor: pspColors.outerBackground,
				},
			},
		},
		MuiDataGrid: {
			styleOverrides: {
				root: {
					border: `1px solid ${pspColors.tableBorder}`,
					fontFamily: pspColors.fontFamily,
					fontSize: pspColors.fontSize,
					lineHeight: pspColors.lineHeight,
					"& .MuiDataGrid-withBorderColor": {
						borderColor: "transparent",
					},
				},
				columnHeaders: {
					backgroundColor: pspColors.headerBackground,
					color: pspColors.headerText,
					fontWeight: 700,
					fontSize: pspColors.fontSize,
					lineHeight: pspColors.lineHeight,
					borderBottom: `1px solid ${pspColors.tableBorder}`,
				},
				columnHeader: {
					backgroundColor: pspColors.headerBackground,
					color: pspColors.headerText,
					fontWeight: 700,
					padding: "2px 8px",
					display: "flex",
					alignItems: "center",
					"&:focus": {
						outline: "none",
					},
					"&:focus-within": {
						outline: "none",
					},
				},
				columnHeaderTitle: {
					fontWeight: 700,
				},
				columnSeparator: {
					color: pspColors.tableBorder,
					"&:hover": {
						color: pspColors.headerText,
					},
				},
				menuIconButton: {
					display: "none",
				},
				iconButtonContainer: {
					visibility: "visible",
				},
				cell: {
					color: pspColors.cellText,
					fontSize: pspColors.fontSize,
					lineHeight: pspColors.lineHeight,
					padding: "0 8px",
					borderBottom: "none",
					display: "flex",
					alignItems: "center",
					"&:focus": {
						outline: "none",
					},
					"&:focus-within": {
						outline: "none",
					},
					// Pinned cells: inherit row background instead of MUI's default white
					"&.MuiDataGrid-cell--pinnedLeft, &.MuiDataGrid-cell--pinnedRight": {
						backgroundColor: "inherit",
					},
				},
				row: {
					border: "none",
					cursor: "pointer",
					// Use class-based striping instead of :nth-of-type for virtualization compatibility
					// Hover rules nested inside stripe rules for proper CSS specificity
					"&.psp-row-odd": {
						backgroundColor: pspColors.cellBackgroundOdd,
						// Explicitly set pinned cell backgrounds (MUI's defaults override inherit)
						"& .MuiDataGrid-cell--pinnedLeft, & .MuiDataGrid-cell--pinnedRight":
							{
								backgroundColor: pspColors.cellBackgroundOdd,
							},
						// Nested hover for higher specificity
						"&:hover, &.psp-row-hover": {
							backgroundColor: pspColors.cellBackgroundHover,
							"& .MuiDataGrid-cell--pinnedLeft, & .MuiDataGrid-cell--pinnedRight":
								{
									backgroundColor: pspColors.cellBackgroundHover,
								},
						},
						// Active (pressed) state darker than hover
						"&:active, &.psp-row-active": {
							backgroundColor: pspColors.cellBackgroundActive,
							"& .MuiDataGrid-cell--pinnedLeft, & .MuiDataGrid-cell--pinnedRight":
								{
									backgroundColor: pspColors.cellBackgroundActive,
								},
						},
					},
					"&.psp-row-even": {
						backgroundColor: pspColors.cellBackgroundEven,
						"& .MuiDataGrid-cell--pinnedLeft, & .MuiDataGrid-cell--pinnedRight":
							{
								backgroundColor: pspColors.cellBackgroundEven,
							},
						// Nested hover for higher specificity
						"&:hover, &.psp-row-hover": {
							backgroundColor: pspColors.cellBackgroundHover,
							"& .MuiDataGrid-cell--pinnedLeft, & .MuiDataGrid-cell--pinnedRight":
								{
									backgroundColor: pspColors.cellBackgroundHover,
								},
						},
						// Active (pressed) state darker than hover
						"&:active, &.psp-row-active": {
							backgroundColor: pspColors.cellBackgroundActive,
							"& .MuiDataGrid-cell--pinnedLeft, & .MuiDataGrid-cell--pinnedRight":
								{
									backgroundColor: pspColors.cellBackgroundActive,
								},
						},
					},
					// Fallback hover for rows without stripe classes
					"&:hover, &.psp-row-hover": {
						backgroundColor: pspColors.cellBackgroundHover,
						"& .MuiDataGrid-cell--pinnedLeft, & .MuiDataGrid-cell--pinnedRight":
							{
								backgroundColor: pspColors.cellBackgroundHover,
							},
					},
					// Fallback active state for rows without stripe classes
					"&:active, &.psp-row-active": {
						backgroundColor: pspColors.cellBackgroundActive,
						"& .MuiDataGrid-cell": {
							color: "#ffffff",
						},
						"& .MuiDataGrid-cell--pinnedLeft, & .MuiDataGrid-cell--pinnedRight":
							{
								backgroundColor: pspColors.cellBackgroundActive,
							},
					},
					"&.Mui-selected": {
						backgroundColor: "#03017c",
						"& .MuiDataGrid-cell": {
							color: "#ffffff",
						},
						"& .MuiDataGrid-cell--pinnedLeft, & .MuiDataGrid-cell--pinnedRight":
							{
								backgroundColor: "#03017c",
							},
						// Override hover to maintain selection color
						"&:hover, &.psp-row-hover": {
							backgroundColor: "#03017c",
							"& .MuiDataGrid-cell--pinnedLeft, & .MuiDataGrid-cell--pinnedRight":
								{
									backgroundColor: "#03017c",
								},
						},
						// Darker shade when clicking (active/pressed state)
						"&:active, &.psp-row-active": {
							backgroundColor: "#020156",
							"& .MuiDataGrid-cell--pinnedLeft, & .MuiDataGrid-cell--pinnedRight":
								{
									backgroundColor: "#020156",
								},
						},
					},
				},
				virtualScroller: {
					// Performance optimizations for virtualized rendering
					willChange: "transform", // Hint browser to optimize for scroll transforms
					contain: "strict", // Isolate layout/paint to this container
					transform: "translateZ(0)", // Force GPU layer for smoother scrolling
				},
				footerContainer: {
					borderTop: `1px solid ${pspColors.tableBorder}`,
					backgroundColor: pspColors.headerBackground,
				},
			},
		},
	},
});

/**
 * CSS classes for special cell styling
 */
export const pspCellStyles = {
	/** Red highlight for Source Code, Confidential columns */
	highlight: {
		color: pspColors.cellTextHighlight,
	},
	/** ALL CAPS for English names */
	uppercase: {
		textTransform: "uppercase" as const,
	},
} as const;

/**
 * Toolbar styles for ward selector and patient stats
 */
export const pspToolbarStyles = {
	toolbar: {
		display: "flex",
		alignItems: "center",
		justifyContent: "space-between",
		padding: "8px 0",
		backgroundColor: "transparent",
	},
	toolbarLeft: {
		display: "flex",
		alignItems: "center",
		gap: "3em",
	},
	toolbarRight: {
		display: "flex",
		alignItems: "center",
		gap: "24px",
	},
	label: {
		fontFamily: pspColors.fontFamily,
		fontSize: "12px",
		fontWeight: 400,
		color: pspColors.toolbarLabelText,
	},
	statLabel: {
		fontFamily: pspColors.fontFamily,
		fontSize: "12px",
		fontWeight: 700,
		color: pspColors.toolbarStatLabelText,
	},
	statValue: {
		fontFamily: pspColors.fontFamily,
		fontSize: "12px",
		fontWeight: 400,
		color: pspColors.toolbarStatValueText,
		backgroundColor: pspColors.toolbarStatValueBackground,
		border: "none",
		borderRadius: "9999px",
		padding: "1px",
		minWidth: "3.5em",
		textAlign: "center" as const,
	},
	select: {
		fontFamily: pspColors.fontFamily,
		fontSize: "12px",
		color: pspColors.selectText,
		backgroundColor: pspColors.selectBackground,
		border: `0.5px solid ${pspColors.selectBorder}`,
		borderRadius: "0px",
		minWidth: "16em",
		height: "2em",
		"& .MuiOutlinedInput-notchedOutline": {
			border: "none",
		},
		"& .MuiSelect-select": {
			padding: "4px 32px 4px 8px",
		},
	},
} as const;

/**
 * Helper to get row class name based on index for virtualization-safe striping.
 * Use with DataGrid's getRowClassName prop.
 *
 * @example
 * <DataGrid
 *   getRowClassName={(params) => getRowClassName(params.indexRelativeToCurrentPage)}
 * />
 */
export function getRowClassName(rowIndex: number): string {
	return rowIndex % 2 === 0 ? "psp-row-odd" : "psp-row-even";
}
