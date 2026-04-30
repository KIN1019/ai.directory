import { Box, Typography } from "@mui/material";

interface MyFirstViewProps {
	viewId?: string;
	path?: string;
}

export const MyFirstView = ({ viewId, path }: MyFirstViewProps) => {
	return (
		<Box>
			<Typography>
				Hello developer, your plugin is loaded successfully!
			</Typography>
			<Typography>
				View {viewId} rendered at {path}
			</Typography>
		</Box>
	);
};
