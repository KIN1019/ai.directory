import type { ReactNode } from "react";
import { Dialog, Button, Box, Typography } from "@mui/material";

/**
 * Rounded warning triangle icon — filled orange with white exclamation mark.
 */
function WarningTriangleIcon({ size = 48 }: { size?: number }) {
	return (
		<svg
			width={size}
			height={size}
			viewBox="0 0 48 48"
			fill="none"
			xmlns="http://www.w3.org/2000/svg"
			style={{ flexShrink: 0 }}
		>
			<path
				d="M22.1 8.6c.8-1.5 3-1.5 3.8 0l16.4 28.8c.8 1.4-.2 3.1-1.9 3.1H7.6c-1.7 0-2.7-1.7-1.9-3.1L22.1 8.6Z"
				fill="#cf4910"
			/>
			<rect x="22" y="16" width="4" height="13" rx="2" fill="#ffffff" />
			<circle cx="24" cy="34" r="2.5" fill="#ffffff" />
		</svg>
	);
}

const buttonGreen = "#168065";
const dialogBorderRadius = "4px";
const buttonBorderRadius = "1px";

export interface YesNoDialogProps {
	/** Whether the dialog is open */
	open: boolean;
	/** Callback when dialog is closed (No clicked or backdrop click) */
	onClose: () => void;
	/** Callback when Yes is clicked */
	onConfirm: () => void;
	/** Message content — can be a string or JSX for multi-paragraph text */
	message: ReactNode;
	/** Text for the Yes button (default: "Yes") */
	yesButtonText?: string;
	/** Text for the No button (default: "No") */
	noButtonText?: string;
}

const dialogStyles = {
	paper: {
		borderRadius: dialogBorderRadius,
		border: "none",
		backgroundColor: "#ffffff",
		boxShadow: "0 4px 24px rgba(0, 0, 0, 0.15)",
		maxWidth: 480,
		width: "100%",
		padding: 0,
		overflow: "hidden",
	},
	content: {
		display: "flex",
		gap: "16px",
		alignItems: "flex-start",
		padding: "24px 24px 20px",
	},
	icon: {
		flexShrink: 0,
		marginTop: "2px",
	},
	message: {
		fontSize: "14px",
		fontWeight: 700,
		color: "#1a1a1a",
		lineHeight: 1.6,
	},
	buttonRow: {
		display: "flex",
		justifyContent: "flex-end",
		gap: "12px",
		padding: "12px 24px",
		backgroundColor: "#f5f5f5",
	},
	noButton: {
		borderRadius: buttonBorderRadius,
		border: `1px solid ${buttonGreen}`,
		color: buttonGreen,
		fontWeight: 600,
		fontSize: "13px",
		textTransform: "none" as const,
		padding: "6px 20px",
		"&:hover": {
			backgroundColor: "rgba(22, 128, 101, 0.05)",
			borderColor: buttonGreen,
		},
	},
	yesButton: {
		borderRadius: buttonBorderRadius,
		backgroundColor: buttonGreen,
		color: "#ffffff",
		fontWeight: 600,
		fontSize: "13px",
		textTransform: "none" as const,
		padding: "6px 24px",
		"&:hover": {
			backgroundColor: "#126b55",
		},
	},
} as const;

/**
 * Modern Yes/No confirmation dialog with warning icon.
 *
 * @example
 * ```tsx
 * <YesNoDialog
 *   open={isOpen}
 *   onClose={() => setIsOpen(false)}
 *   onConfirm={() => { handleConfirm(); setIsOpen(false); }}
 *   message={
 *     <>
 *       You are attempting to access a patient's record which you might
 *       NOT be authorized.
 *       <br /><br />
 *       Do you wish to continue?
 *     </>
 *   }
 * />
 * ```
 */
export function YesNoDialog({
	open,
	onClose,
	onConfirm,
	message,
	yesButtonText = "Yes",
	noButtonText = "No",
}: YesNoDialogProps) {
	return (
		<Dialog
			open={open}
			onClose={onClose}
			PaperProps={{ sx: dialogStyles.paper }}
		>
			{/* Content: icon + message */}
			<Box sx={dialogStyles.content}>
				<Box sx={dialogStyles.icon}>
					<WarningTriangleIcon size={48} />
				</Box>
				<Typography component="div" sx={dialogStyles.message}>
					{message}
				</Typography>
			</Box>

			{/* Button row */}
			<Box sx={dialogStyles.buttonRow}>
				<Button variant="outlined" onClick={onClose} sx={dialogStyles.noButton}>
					{noButtonText}
				</Button>
				<Button
					variant="contained"
					onClick={onConfirm}
					sx={dialogStyles.yesButton}
					disableElevation
				>
					{yesButtonText}
				</Button>
			</Box>
		</Dialog>
	);
}
