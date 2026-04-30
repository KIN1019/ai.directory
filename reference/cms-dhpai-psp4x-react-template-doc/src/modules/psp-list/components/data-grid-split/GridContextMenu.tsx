import { useState, useCallback, useMemo } from "react";
import {
	Menu,
	MenuItem,
	Divider,
	ListItemIcon,
	ListItemText,
	Box,
} from "@mui/material";
import {
	Check as CheckIcon,
	ArrowRight as ArrowRightIcon,
	ArrowUpward as AscIcon,
	ArrowDownward as DescIcon,
} from "@mui/icons-material";
import type {
	GridColDef,
	GridSortModel,
	GridSortDirection,
} from "@mui/x-data-grid-pro";
import { pspColors } from "../../theme/pspTheme";
import type { ContextMenuPosition } from "../../hooks/useContextMenu";
import type { ContextMenuItem } from "../../types";

/**
 * Props for the internal GridContextMenu component.
 * This component is internal to SplitPanelRenderer and should not be used directly.
 */
export interface GridContextMenuProps<
	T extends ContextMenuItem = ContextMenuItem,
> {
	/** Whether the context menu is open */
	open: boolean;
	/** Position of the context menu */
	position: ContextMenuPosition | null;
	/** Callback when the context menu is closed */
	onClose: () => void;
	/** Menu items to display (generic) */
	menuItems: readonly T[];
	/** Currently selected item ID */
	selectedItemId: string | null;
	/** Callback when an item is selected */
	onItemSelect: (item: T) => void;
	/** Column definitions for sort options */
	columns: readonly GridColDef[];
	/** Current sort model */
	sortModel: GridSortModel;
	/** Callback when sort is changed */
	onSortModelChange: (model: GridSortModel) => void;
}

/** Styles for context menu */
const menuStyles = {
	paper: {
		minWidth: 240,
		boxShadow: "0 4px 12px rgba(0,0,0,0.15)",
		border: `1px solid ${pspColors.tableBorder}`,
		"& .MuiMenuItem-root": {
			fontSize: "12px",
			fontFamily: pspColors.fontFamily,
			padding: "4px 12px",
			"&:hover": {
				backgroundColor: pspColors.cellBackgroundHover,
			},
		},
		"& .MuiDivider-root": {
			margin: "4px 0",
		},
	},
} as const;

const submenuStyles = {
	paper: {
		minWidth: 180,
		maxHeight: 350,
		boxShadow: "0 4px 12px rgba(0,0,0,0.15)",
		border: `1px solid ${pspColors.tableBorder}`,
		"& .MuiMenuItem-root": {
			fontSize: "12px",
			fontFamily: pspColors.fontFamily,
			padding: "4px 12px",
			"&:hover": {
				backgroundColor: pspColors.cellBackgroundHover,
			},
		},
		"& .MuiListItemText-primary": {
			fontSize: "12px",
		},
	},
} as const;

/**
 * Context menu for the data grid with generic item selection and sort options.
 * This component is internal to SplitPanelRenderer and should not be used directly.
 */
export function GridContextMenu<T extends ContextMenuItem = ContextMenuItem>({
	open,
	position,
	onClose,
	menuItems,
	selectedItemId,
	onItemSelect,
	columns,
	sortModel,
	onSortModelChange,
}: GridContextMenuProps<T>) {
	// State for sort submenu
	const [sortMenuAnchor, setSortMenuAnchor] = useState<HTMLElement | null>(
		null,
	);
	const sortMenuOpen = Boolean(sortMenuAnchor);

	// Sortable columns (filter out non-sortable columns)
	const sortableColumns = useMemo(
		() =>
			columns.filter((col) => col.sortable !== false && col.field !== "locked"),
		[columns],
	);

	// Current sort field and direction
	const currentSort = sortModel[0];

	// Handle menu item selection
	const handleItemClick = useCallback(
		(item: T) => {
			onItemSelect(item);
			onClose();
		},
		[onItemSelect, onClose],
	);

	// Handle sort menu hover
	const handleSortMenuOpen = useCallback(
		(event: React.MouseEvent<HTMLElement>) => {
			setSortMenuAnchor(event.currentTarget);
		},
		[],
	);

	const handleSortMenuClose = useCallback(() => {
		setSortMenuAnchor(null);
	}, []);

	// Handle sort column selection
	const handleSortClick = useCallback(
		(field: string, direction: GridSortDirection) => {
			const newSortModel: GridSortModel = direction
				? [{ field, sort: direction }]
				: [];
			onSortModelChange(newSortModel);
			handleSortMenuClose();
			onClose();
		},
		[onSortModelChange, handleSortMenuClose, onClose],
	);

	// Handle menu close
	const handleClose = useCallback(() => {
		handleSortMenuClose();
		onClose();
	}, [handleSortMenuClose, onClose]);

	if (!position) return null;

	return (
		<>
			{/* Main Context Menu */}
			<Menu
				open={open}
				onClose={handleClose}
				anchorReference="anchorPosition"
				anchorPosition={{ top: position.mouseY, left: position.mouseX }}
				slotProps={{
					paper: { sx: menuStyles.paper },
				}}
			>
				{/* Generic Menu Items */}
				{menuItems.length > 0 && (
					<Box>
						{menuItems.map((item) => {
							const isSelected = selectedItemId === item.id;
							return (
								<MenuItem
									key={item.id}
									onClick={() => handleItemClick(item)}
									dense
									sx={{ minHeight: 28, py: 0.25 }}
								>
									<ListItemIcon
										sx={{
											minWidth: 14,
											"& .MuiSvgIcon-root": { fontSize: 12 },
										}}
									>
										{isSelected && (
											<CheckIcon sx={{ color: "#444444", fontSize: 12 }} />
										)}
									</ListItemIcon>
									<ListItemText
										primary={item.label}
										primaryTypographyProps={{
											fontSize: "12px",
											fontWeight: isSelected ? 600 : 400,
											color: "#444444",
											noWrap: true,
										}}
									/>
								</MenuItem>
							);
						})}
					</Box>
				)}

				{menuItems.length > 0 && <Divider />}

				{/* Sort Section */}
				<MenuItem
					onMouseEnter={handleSortMenuOpen}
					onMouseLeave={handleSortMenuClose}
					sx={{ position: "relative", minHeight: 28 }}
				>
					<ListItemText
						primary="Sort By"
						primaryTypographyProps={{
							fontSize: "12px",
							color: "#444444",
						}}
					/>
					<ArrowRightIcon
						fontSize="small"
						sx={{ color: "#444444", fontSize: 14 }}
					/>

					{/* Sort Submenu */}
					<Menu
						open={sortMenuOpen}
						anchorEl={sortMenuAnchor}
						onClose={handleSortMenuClose}
						anchorOrigin={{ vertical: "top", horizontal: "right" }}
						transformOrigin={{ vertical: "top", horizontal: "left" }}
						slotProps={{
							paper: { sx: submenuStyles.paper },
						}}
						sx={{ pointerEvents: "none" }}
						MenuListProps={{
							onMouseEnter: () => setSortMenuAnchor(sortMenuAnchor),
							onMouseLeave: handleSortMenuClose,
							sx: { pointerEvents: "auto" },
						}}
					>
						{sortableColumns.map((col) => {
							const isCurrentField = currentSort?.field === col.field;
							const currentDirection = isCurrentField ? currentSort.sort : null;

							return (
								<Box key={col.field}>
									<MenuItem
										onClick={() =>
											handleSortClick(
												col.field,
												currentDirection === "asc" ? null : "asc",
											)
										}
										selected={isCurrentField && currentDirection === "asc"}
									>
										<ListItemIcon sx={{ minWidth: 28 }}>
											<AscIcon fontSize="small" sx={{ color: "#444444" }} />
										</ListItemIcon>
										<ListItemText
											primary={`${col.headerName || col.field} (Asc)`}
											primaryTypographyProps={{
												fontSize: "12px",
												fontWeight:
													isCurrentField && currentDirection === "asc"
														? 600
														: 400,
												color: "#444444",
											}}
										/>
									</MenuItem>
									<MenuItem
										onClick={() =>
											handleSortClick(
												col.field,
												currentDirection === "desc" ? null : "desc",
											)
										}
										selected={isCurrentField && currentDirection === "desc"}
									>
										<ListItemIcon sx={{ minWidth: 28 }}>
											<DescIcon fontSize="small" sx={{ color: "#444444" }} />
										</ListItemIcon>
										<ListItemText
											primary={`${col.headerName || col.field} (Desc)`}
											primaryTypographyProps={{
												fontSize: "12px",
												fontWeight:
													isCurrentField && currentDirection === "desc"
														? 600
														: 400,
												color: "#444444",
											}}
										/>
									</MenuItem>
									<Divider sx={{ my: 0.5 }} />
								</Box>
							);
						})}
					</Menu>
				</MenuItem>
			</Menu>
		</>
	);
}
