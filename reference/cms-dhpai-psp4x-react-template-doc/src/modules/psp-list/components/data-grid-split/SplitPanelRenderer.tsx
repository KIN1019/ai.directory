import { useCallback, useRef, useEffect } from "react";
import type {
	GridColDef,
	GridSortModel,
	GridRowSelectionModel,
	GridValidRowModel,
	GridApi,
	GridRowParams,
} from "@mui/x-data-grid-pro";
import { Box } from "@mui/material";
import type { SxProps, Theme } from "@mui/material";

// #region agent log
const _DBG_ENDPOINT =
	"http://127.0.0.1:7242/ingest/14ec58d7-a42d-48a0-b5df-766ce3885083";
let _renderCount = 0;
// #endregion
import { DraggableDivider } from "./DraggableDivider";
import { GridContextMenu } from "./GridContextMenu";
import { useSplitPanelScroll } from "../../hooks/useSplitPanelScroll";
import { useSyncRowHover } from "../../hooks/useSyncRowHover";
import { useSyncRowActive } from "../../hooks/useSyncRowActive";
import { useKeyboardRowNavigation } from "../../hooks/useKeyboardRowNavigation";
import {
	useRowConfirmation,
	type RowConfirmationHandler,
} from "../../hooks/useRowConfirmation";
import { useSplitPanelState } from "../../hooks/useSplitPanelState";
import { getRowClassName } from "../../theme/pspTheme";
import {
	GRID_COMMON_SX,
	GRID_FLEX_LAST_COLUMN_SX,
	GRID_HIDE_SCROLLBAR_SX,
	getPanelContainerSx,
	getGridBorderSx,
} from "./styles";
import type { SplitPanelConfig, GridCallbackDetails } from "../../types";

interface SplitPanelRendererProps<TProps extends object> {
	/** The grid component to render */
	gridComponent: React.ComponentType<TProps>;
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
	/** Row height */
	rowHeight: number;
	/** Column header height */
	columnHeaderHeight: number;
	/** Slot overrides */
	slots?: Record<string, unknown>;
	/** Slot props */
	slotProps?: Record<string, unknown>;
	/** Whether to show checkboxes */
	checkboxSelection?: boolean;
	/** Whether to disable column menu */
	disableColumnMenu?: boolean;
	/** MUI System sx prop */
	sx?: SxProps<Theme>;
	/** Rest of the props to pass through to the grid */
	restProps: Record<string, unknown>;
	/** Callback when a row is confirmed (Enter key or double-click) */
	onRowConfirm?: RowConfirmationHandler;
	/** Context menu configuration (optional) */
	contextMenuConfig?: import("../../types").ContextMenuConfig;
}

export function SplitPanelRenderer<TProps extends object>({
	gridComponent: GridComponent,
	columns,
	rows,
	panelConfigs,
	controlledSortModel,
	onSortModelChange,
	controlledRowSelectionModel,
	onRowSelectionModelChange,
	rowHeight,
	columnHeaderHeight,
	slots,
	slotProps,
	checkboxSelection,
	disableColumnMenu,
	sx,
	restProps,
	onRowConfirm,
	contextMenuConfig,
}: SplitPanelRendererProps<TProps>) {
	// #region agent log
	_renderCount++;
	const _renderCountRef = useRef(0);
	_renderCountRef.current = _renderCount;
	useEffect(() => {
		const iv = setInterval(() => {
			fetch(_DBG_ENDPOINT, {
				method: "POST",
				headers: { "Content-Type": "application/json" },
				body: JSON.stringify({
					location: "SplitPanelRenderer.tsx",
					message: "PERIODIC SUMMARY",
					data: { renderCount: _renderCountRef.current },
					timestamp: Date.now(),
					sessionId: "debug-session",
					hypothesisId: "E",
				}),
			}).catch(() => {});
		}, 3000);
		return () => clearInterval(iv);
	}, []);
	// #endregion

	// Consolidated state management via composite hook
	const {
		containerRef,
		contextMenuPosition,
		handleContextMenu,
		handleCloseContextMenu,
		menuItems,
		selectedItemId,
		handleMenuItemSelect,
		resolvedPanels,
		apiRefs,
		panelWidths,
		createDividerDragHandler,
		sortModel,
		sortedRows,
		handleSortModelChange,
		rowSelectionModel,
		handleRowSelectionModelChange,
	} = useSplitPanelState({
		columns,
		rows,
		panelConfigs,
		controlledSortModel,
		onSortModelChange,
		controlledRowSelectionModel,
		onRowSelectionModelChange,
		contextMenuConfig,
	});

	// Disable MUI's row virtualization for small-to-medium datasets.
	// Virtualization causes progressive lag during rapid scrolling because each
	// scroll position change triggers MUI to create/destroy row React elements,
	// generating ~1.2MB of garbage per event and causing GC pressure.
	// Without virtualization, all rows are pre-rendered in the DOM and scrolling
	// is handled by the browser's compositor thread — zero JS, zero GC.
	// 500 rows × 2 panels × ~10 columns ≈ 10,000 cells, well within browser limits.
	const VIRTUALIZATION_ROW_THRESHOLD = 500;
	const useNativeScroll = sortedRows.length <= VIRTUALIZATION_ROW_THRESHOLD;

	// Unified scroll sync across all panels (wheel, scrollbar, keyboard)
	const { scrollToRowIndex } = useSplitPanelScroll({
		apiRefs: apiRefs as React.MutableRefObject<GridApi | null>[],
		config: {
			rowHeight,
			nativeScroll: useNativeScroll,
		},
	});

	// Sync row hover state across all panels (direct DOM manipulation for zero-delay)
	useSyncRowHover({ containerRef });

	// Sync row active (pressed) state across all panels
	useSyncRowActive({ containerRef });

	// Row confirmation handler (pluggable - currently console.log placeholder)
	const { confirmRow } = useRowConfirmation({ onConfirm: onRowConfirm });

	// Keyboard navigation handler for row selection updates
	const handleKeyboardSelectionChange = useCallback(
		(model: GridRowSelectionModel) => {
			handleRowSelectionModelChange(model);
		},
		[handleRowSelectionModelChange],
	);

	// Keyboard row navigation (ArrowUp/ArrowDown to move selection, Enter to confirm)
	// Uses scrollToRowIndex from useSplitPanelScroll for synchronized scrolling
	useKeyboardRowNavigation({
		sortedRows,
		rowSelectionModel,
		onRowSelectionModelChange: handleKeyboardSelectionChange,
		onRowConfirm: confirmRow,
		containerElement: containerRef.current,
		scrollToRowIndex,
	});

	// Handle double-click to confirm row
	const handleRowDoubleClick = useCallback(
		(params: GridRowParams) => {
			confirmRow(params.id);
		},
		[confirmRow],
	);

	// Non-primary panels: row click sets selection (so we don't attach onRowSelectionModelChange to them and get spurious []).
	const handleNonPrimaryRowClick = useCallback(
		(params: GridRowParams) => {
			handleRowSelectionModelChange([params.id]);
		},
		[handleRowSelectionModelChange],
	);

	// Memoized row class name getter for stable reference
	const getRowClassNameCallback = useCallback(
		(params: { indexRelativeToCurrentPage: number }) =>
			getRowClassName(params.indexRelativeToCurrentPage),
		[],
	);

	// Shared props for all grids
	const sharedProps = {
		rows: sortedRows,
		sortModel,
		onSortModelChange: handleSortModelChange,
		sortingMode: "server" as const, // Disable internal sorting since we sort at parent level
		rowSelectionModel,
		rowHeight,
		columnHeaderHeight,
		disableColumnMenu,
		hideFooter: true, // Always hide footer in split mode
		disableMultipleRowSelection: true, // Single selection mode only
		disableVirtualization: sortedRows.length <= VIRTUALIZATION_ROW_THRESHOLD,
		slots,
		slotProps,
		getRowClassName: getRowClassNameCallback,
	};

	// Render panels with dividers between them
	const renderPanels = () => {
		return resolvedPanels.flatMap((panel, index) => {
			const isFirst = index === 0;
			const isLast = panel.isLast;
			const elements: React.ReactNode[] = [];

			// Add divider before panel (except for first panel)
			if (!isFirst) {
				elements.push(
					<DraggableDivider
						key={`divider-${index}`}
						onDrag={createDividerDragHandler(index - 1)}
					/>,
				);
			}

			// Build sx prop array using extracted style constants
			const sxArray: SxProps<Theme>[] = [
				GRID_COMMON_SX,
				...(isLast ? [GRID_FLEX_LAST_COLUMN_SX] : []),
				getGridBorderSx(isFirst, isLast),
				...(isLast ? [] : [GRID_HIDE_SCROLLBAR_SX]),
				...(Array.isArray(sx) ? sx : sx ? [sx] : []),
			];

			elements.push(
				<Box
					key={`panel-${index}`}
					sx={getPanelContainerSx(isLast, panel.minWidth, panelWidths[index])}
				>
					<GridComponent
						{...(restProps as unknown as TProps)}
						{...(sharedProps as unknown as Partial<TProps>)}
						apiRef={apiRefs[index]}
						columns={panel.columns}
						onRowSelectionModelChange={
							isFirst ? handleRowSelectionModelChange : undefined
						}
						onRowClick={isFirst ? undefined : handleNonPrimaryRowClick}
						onRowDoubleClick={handleRowDoubleClick}
						checkboxSelection={isFirst ? checkboxSelection : false}
						sx={sxArray}
					/>
				</Box>,
			);

			return elements;
		});
	};

	// Context menu sort handler
	const handleContextMenuSort = useCallback(
		(model: GridSortModel) => {
			handleSortModelChange(model);
		},
		[handleSortModelChange],
	);

	const DIVIDER_WIDTH = 6;
	const containerMinWidth =
		resolvedPanels.reduce((sum, p) => sum + p.minWidth, 0) +
		DIVIDER_WIDTH * (resolvedPanels.length - 1);

	return (
		<Box
			ref={containerRef}
			onContextMenu={handleContextMenu}
			sx={{
				display: "flex",
				width: "100%",
				minWidth: containerMinWidth,
				height: "100%",
				overflowX: "auto",
				overflowY: "hidden",
			}}
		>
			{renderPanels()}
			<GridContextMenu
				open={contextMenuPosition !== null}
				position={contextMenuPosition}
				onClose={handleCloseContextMenu}
				menuItems={menuItems}
				selectedItemId={selectedItemId}
				onItemSelect={handleMenuItemSelect}
				columns={columns}
				sortModel={sortModel}
				onSortModelChange={handleContextMenuSort}
			/>
		</Box>
	);
}
