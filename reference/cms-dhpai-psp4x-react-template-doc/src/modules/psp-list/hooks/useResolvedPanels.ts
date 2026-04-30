import { useMemo } from "react";
import type { GridColDef } from "@mui/x-data-grid-pro";
import {
	type SplitPanelConfig,
	type ResolvedPanel,
	DEFAULT_MIN_WIDTH,
	LAST_PANEL_MIN_WIDTH,
} from "../types";

const MUI_DEFAULT_COLUMN_WIDTH = 100;

/**
 * Computes the effective rendered width for a single DataGrid column.
 *
 * MUI DataGrid sizing: when no explicit `width` is set, the column renders
 * at max(100, minWidth), then clamps to maxWidth if present.
 */
function effectiveColumnWidth(col: GridColDef): number {
	if (col.width !== undefined) return col.width;
	const base = Math.max(MUI_DEFAULT_COLUMN_WIDTH, col.minWidth ?? 0);
	return col.maxWidth !== undefined ? Math.min(base, col.maxWidth) : base;
}

// MUI DataGrid column separator handles extend ~2px per column beyond the
// header content. The grid also has its own 1px border on each side.
// These are added so the panel container fully covers the grid's scrollWidth.
const MUI_COLUMN_SEPARATOR_PX = 2;
const MUI_GRID_BORDER_PX = 2;

/**
 * Computes the natural initial width for a panel based on its columns,
 * matching MUI DataGrid's actual scrollWidth (column widths + separators + border).
 */
function computeColumnsWidth(columns: GridColDef[]): number {
	const columnsTotal = columns.reduce(
		(sum, col) => sum + effectiveColumnWidth(col),
		0,
	);
	return (
		columnsTotal + columns.length * MUI_COLUMN_SEPARATOR_PX + MUI_GRID_BORDER_PX
	);
}

/**
 * Hook to resolve panel configurations by computing columns for each panel.
 *
 * Takes panel configs with field names and resolves them to actual GridColDef arrays.
 * Creates a final panel with any remaining columns not assigned to explicit panels.
 *
 * @param columns - All available column definitions
 * @param panelConfigs - User-defined panel configurations
 * @returns Array of resolved panels with computed columns and settings
 */
export function useResolvedPanels(
	columns: readonly GridColDef[],
	panelConfigs: SplitPanelConfig[],
): ResolvedPanel[] {
	return useMemo((): ResolvedPanel[] => {
		const assignedFields = new Set<string>();
		const result: ResolvedPanel[] = [];

		// Process each configured panel
		panelConfigs.forEach((config) => {
			const panelColumns: GridColDef[] = [];
			config.fields.forEach((field) => {
				const col = columns.find((c) => c.field === field);
				if (col && !assignedFields.has(field)) {
					panelColumns.push(col);
					assignedFields.add(field);
				}
			});

			// Preserve order from config.fields
			panelColumns.sort(
				(a, b) =>
					config.fields.indexOf(a.field) - config.fields.indexOf(b.field),
			);

			const columnsWidth = computeColumnsWidth(panelColumns);
			result.push({
				columns: panelColumns,
				initialWidth: config.initialWidth ?? columnsWidth,
				minWidth: config.minWidth ?? DEFAULT_MIN_WIDTH,
				isLast: false,
			});
		});

		// Add final panel with remaining columns
		const remainingColumns = columns.filter(
			(col) => !assignedFields.has(col.field),
		);
		result.push({
			columns: remainingColumns,
			initialWidth: 0, // Last panel uses flex
			minWidth: LAST_PANEL_MIN_WIDTH,
			isLast: true,
		});

		return result;
	}, [columns, panelConfigs]);
}
