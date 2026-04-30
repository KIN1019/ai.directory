import { Box } from "@mui/material";
import ArrowDropUpIcon from "@mui/icons-material/ArrowDropUp";
import ArrowDropDownIcon from "@mui/icons-material/ArrowDropDown";
import type { GridSortDirection } from "@mui/x-data-grid-pro";
import { pspColors } from "../../theme/pspTheme";

interface SortIconProps {
	direction: GridSortDirection;
	/** Color for the active sort direction arrow */
	activeColor?: string;
	/** Color for the inactive sort direction arrow */
	inactiveColor?: string;
	/** Size of each triangle icon in pixels */
	size?: number;
}

/**
 * Custom sort icon showing both up and down arrows.
 * The active direction is highlighted.
 */
export function SortIcon({
	direction,
	activeColor = pspColors.headerText,
	inactiveColor = "#a0a0a0",
	size = 12,
}: SortIconProps) {
	return (
		<Box
			sx={{
				display: "flex",
				flexDirection: "column",
				alignItems: "center",
				justifyContent: "center",
				lineHeight: 0,
				marginTop: "-4px",
				marginBottom: "-4px",
			}}
		>
			<ArrowDropUpIcon
				sx={{
					fontSize: size,
					color: direction === "asc" ? activeColor : inactiveColor,
					marginBottom: "-4px",
				}}
			/>
			<ArrowDropDownIcon
				sx={{
					fontSize: size,
					color: direction === "desc" ? activeColor : inactiveColor,
					marginTop: "-4px",
				}}
			/>
		</Box>
	);
}

// Pre-built slot components for DataGrid
export const SortIconAsc = () => <SortIcon direction="asc" />;
export const SortIconDesc = () => <SortIcon direction="desc" />;
export const SortIconUnsorted = () => <SortIcon direction={null} />;
