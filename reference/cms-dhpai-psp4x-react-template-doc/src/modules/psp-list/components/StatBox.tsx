import { Box, Typography } from "@mui/material";

import { pspToolbarStyles } from "../theme/pspTheme";

export interface StatBoxProps {
	/** Label text displayed before the value */
	label: string;
	/** Numeric value to display */
	value: number;
}

/**
 * Stat box component displaying a label with a boxed numeric value.
 */
export function StatBox({ label, value }: StatBoxProps) {
	return (
		<Box sx={{ display: "flex", alignItems: "center", gap: "8px" }}>
			<Typography component="span" sx={pspToolbarStyles.statLabel}>
				{label}
			</Typography>
			<Box component="span" sx={pspToolbarStyles.statValue}>
				{value}
			</Box>
		</Box>
	);
}
