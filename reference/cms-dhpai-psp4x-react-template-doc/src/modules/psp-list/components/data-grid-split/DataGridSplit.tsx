import { useMemo } from "react";
import { SortIconAsc, SortIconDesc, SortIconUnsorted } from "./SortIcon";
import { SplitPanelRenderer } from "./SplitPanelRenderer";
import type { DataGridSplitProps } from "../../types";

/**
 * Default slots for DataGridSplit with custom sort icons.
 * Users can override any of these by passing their own slots.
 */
const DEFAULT_SLOTS = {
	columnSortedAscendingIcon: SortIconAsc,
	columnSortedDescendingIcon: SortIconDesc,
	columnUnsortedIcon: SortIconUnsorted,
};

/**
 * DataGridSplit - A DataGrid wrapper that enables horizontally scrollable
 * split panels with synchronized vertical scrolling.
 *
 * The grid component must be passed explicitly via the `gridComponent` prop.
 *
 * @example
 * ```tsx
 * import { DataGrid } from "@mui/x-data-grid-pro";
 *
 * <DataGridSplit
 *   gridComponent={DataGrid}
 *   rows={rows}
 *   columns={columns}
 *   splitPanels={[
 *     { fields: ['bed', 'name'], initialWidth: 250 },
 *     { fields: ['age', 'city'], initialWidth: 300 },
 *   ]}
 * />
 * ```
 */
export function DataGridSplit<TProps extends object>(
	props: DataGridSplitProps<TProps>,
): React.ReactElement {
	const {
		gridComponent: GridComponent,
		splitPanels,
		initialState,
		slots,
		rows,
		columns,
		sortModel,
		onSortModelChange,
		rowSelectionModel,
		onRowSelectionModelChange,
		rowHeight = 52,
		columnHeaderHeight = 56,
		onRowConfirm,
		contextMenuConfig,
		...restProps
	} = props;

	const mergedSlots = useMemo(() => ({ ...DEFAULT_SLOTS, ...slots }), [slots]);

	// Normalize: prefer splitPanels, fall back to pinnedColumns.left for backward compat
	const pinnedLeft = (
		initialState as { pinnedColumns?: { left?: string[] } } | undefined
	)?.pinnedColumns?.left;
	const panelConfigs = splitPanels?.length
		? splitPanels
		: pinnedLeft?.length
			? [{ fields: pinnedLeft }]
			: null;

	// Non-split mode: pass through to GridComponent
	if (!panelConfigs) {
		const gridProps = {
			...restProps,
			initialState,
			rows,
			columns,
			sortModel,
			onSortModelChange,
			rowSelectionModel,
			onRowSelectionModelChange,
			rowHeight,
			columnHeaderHeight,
		};
		return (
			<GridComponent
				{...(gridProps as unknown as TProps)}
				slots={mergedSlots}
			/>
		);
	}

	// Split mode: render multiple synchronized panels
	return (
		<SplitPanelRenderer<TProps>
			gridComponent={GridComponent}
			rows={rows}
			columns={columns}
			panelConfigs={panelConfigs}
			controlledSortModel={sortModel}
			onSortModelChange={onSortModelChange}
			controlledRowSelectionModel={rowSelectionModel}
			onRowSelectionModelChange={onRowSelectionModelChange}
			rowHeight={rowHeight}
			columnHeaderHeight={columnHeaderHeight}
			slots={mergedSlots}
			restProps={restProps}
			onRowConfirm={onRowConfirm}
			contextMenuConfig={contextMenuConfig}
		/>
	);
}
