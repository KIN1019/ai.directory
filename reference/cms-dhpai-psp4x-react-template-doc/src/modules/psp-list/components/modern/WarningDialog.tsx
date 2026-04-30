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
			{/* Exclamation bar */}
			<rect x="22" y="16" width="4" height="13" rx="2" fill="#ffffff" />
			{/* Exclamation dot */}
			<circle cx="24" cy="34" r="2.5" fill="#ffffff" />
		</svg>
	);
}

const buttonGreen = "#168065";
const dialogBorderRadius = "4px";
const buttonBorderRadius = "1px";

export interface WarningDialogProps {
	/** Whether the dialog is open */
	open: boolean;
	/** Callback when dialog is closed (Cancel or backdrop click) */
	onClose: () => void;
	/** Callback when OK button is clicked */
	onConfirm: () => void;
	/** Bold heading message */
	title: string;
	/** Optional description text shown below the title */
	description?: string;
	/** Text for the OK button (default: "OK") */
	okButtonText?: string;
	/** Text for the Cancel button (default: "Cancel") */
	cancelButtonText?: string;
	/** Hide the cancel button (default: false) */
	hideCancelButton?: boolean;
}

const dialogStyles = {
	paper: {
		borderRadius: dialogBorderRadius,
		border: "none",
		backgroundColor: "#ffffff",
		boxShadow: "0 4px 24px rgba(0, 0, 0, 0.15)",
		maxWidth: 480,
		width: "100%",
		padding: "24px",
	},
	content: {
		display: "flex",
		gap: "16px",
		alignItems: "flex-start",
	},
	icon: {
		flexShrink: 0,
		marginTop: "2px",
	},
	title: {
		fontSize: "14px",
		fontWeight: 700,
		color: "#1a1a1a",
		lineHeight: 1.5,
	},
	description: {
		fontSize: "13px",
		fontWeight: 400,
		color: "#555555",
		lineHeight: 1.5,
		marginTop: "4px",
	},
	buttonRow: {
		display: "flex",
		justifyContent: "flex-end",
		gap: "12px",
		marginTop: "20px",
	},
	cancelButton: {
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
	okButton: {
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
 * Modern warning dialog with clean design.
 *
 * @example
 * ```tsx
 * <WarningDialog
 *   open={isOpen}
 *   onClose={() => setIsOpen(false)}
 *   onConfirm={() => { handleConfirm(); setIsOpen(false); }}
 *   title='More than one patient with this name "LAM MEI CHEN" is found on the patient list.'
 *   description="Check on the patient's particulars to confirm the selected patient before proceed"
 * />
 * ```
 */
export function WarningDialog({
	open,
	onClose,
	onConfirm,
	title,
	description,
	okButtonText = "OK",
	cancelButtonText = "Cancel",
	hideCancelButton = false,
}: WarningDialogProps) {
	return (
		<Dialog
			open={open}
			onClose={onClose}
			PaperProps={{ sx: dialogStyles.paper }}
		>
			<Box sx={dialogStyles.content}>
				<Box sx={dialogStyles.icon}>
					<WarningTriangleIcon size={48} />
				</Box>
				<Box>
					<Typography sx={dialogStyles.title}>{title}</Typography>
					{description && (
						<Typography sx={dialogStyles.description}>{description}</Typography>
					)}
				</Box>
			</Box>

			<Box sx={dialogStyles.buttonRow}>
				{!hideCancelButton && (
					<Button
						variant="outlined"
						onClick={onClose}
						sx={dialogStyles.cancelButton}
					>
						{cancelButtonText}
					</Button>
				)}
				<Button
					variant="contained"
					onClick={onConfirm}
					sx={dialogStyles.okButton}
					disableElevation
				>
					{okButtonText}
				</Button>
			</Box>
		</Dialog>
	);
}
