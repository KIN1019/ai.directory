import { Box, Typography } from "@mui/material";

interface MySecondViewProps {
	viewId?: string;
	path?: string;
}

export const MySecondView = ({ viewId, path }: MySecondViewProps) => {
	return (
		<Box>
			<Typography>
				Hello developer, your 2nd view is loaded successfully!
			</Typography>
			<Typography>
				View {viewId} rendered at {path}
			</Typography>
		</Box>
	);
};
