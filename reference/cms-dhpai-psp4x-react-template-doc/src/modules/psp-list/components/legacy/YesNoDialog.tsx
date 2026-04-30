import { Dialog, Button, Box, Typography } from "@mui/material";

import { pspColors } from "../../theme/pspTheme";

export interface YesNoDialogProps {
	/** Whether the dialog is open */
	open: boolean;
	/** Callback when dialog is closed (No clicked) */
	onClose: () => void;
	/** Callback when Yes is clicked */
	onConfirm: () => void;
	/** Dialog title displayed in the header */
	title: string;
	/** Message content to display */
	message: string | React.ReactNode;
	/** Text for the Yes button (default: "Yes") */
	yesButtonText?: string;
	/** Text for the No button (default: "No") */
	noButtonText?: string;
	/** Alert mode - turns text blue and shows red rectangle above content */
	alert?: boolean;
}

const dialogStyles = {
	paper: {
		borderRadius: "3px",
		border: `1px solid ${pspColors.tableBorder}`,
		boxShadow: "4px 4px 8px rgba(0, 0, 0, 0.3)",
		minWidth: 400,
		maxWidth: 500,
		overflow: "hidden",
	},
	// Title bar - gradient from d6d6d6 to e9e9e9
	title: {
		display: "flex",
		alignItems: "center",
		justifyContent: "space-between",
		padding: "0 4px",
		background: "linear-gradient(to bottom, #d6d6d6 0%, #e9e9e9 100%)",
		minHeight: 18,
		borderBottom: "1px solid #e2e2e2",
	},
	titleText: {
		fontFamily: pspColors.fontFamily,
		fontSize: "10px",
		fontWeight: 700,
		color: "#444444",
		lineHeight: 1,
	},
	// Outer container starting from e9e9e9 (where title left off)
	outerContainer: {
		background: "linear-gradient(to bottom, #e9e9e9 0%, #f5f5f5 100%)",
		padding: "4px",
	},
	// White inner content box
	innerContainer: {
		backgroundColor: "#ffffff",
		borderRadius: "2px",
		border: `1px solid ${pspColors.tableBorder}`,
		padding: "16px",
		paddingTop: "0",
	},
	innerContainerNoAlert: {
		backgroundColor: "#ffffff",
		borderRadius: "2px",
		border: `1px solid ${pspColors.tableBorder}`,
		padding: "16px",
	},
	// Red alert rectangle - shown at top of content box
	alertBar: {
		backgroundColor: "#ed1c24",
		height: "5px",
		marginBottom: "16px",
		marginLeft: "-16px",
		marginRight: "-16px",
		marginTop: "0",
	},
	// Message text styling
	message: {
		fontFamily: pspColors.fontFamily,
		fontSize: "11px",
		fontWeight: 400,
		color: "#000000",
		lineHeight: 1.5,
		marginBottom: "16px",
	},
	messageAlert: {
		fontFamily: pspColors.fontFamily,
		fontSize: "11px",
		fontWeight: 400,
		color: "#2f37ff", // Blue text in alert mode
		lineHeight: 1.5,
		marginBottom: "16px",
	},
	// 3D button style - gray gradient (peaks in middle)
	button: {
		fontFamily: pspColors.fontFamily,
		fontSize: "11px",
		fontWeight: 700,
		textTransform: "none" as const,
		background:
			"linear-gradient(to bottom, #fbfbfb 0%, #ffffff 40%, #c7c7c7 100%)",
		border: "1px solid #9e9e9e",
		borderRadius: "9999px",
		padding: "0 24px",
		color: "#000000",
		minWidth: 80,
		minHeight: "auto",
		lineHeight: 1.6,
		"&:hover": {
			background:
				"linear-gradient(to bottom, #ffffff 0%, #ffffff 40%, #d0d0d0 100%)",
		},
	},
} as const;

/**
 * Yes/No dialog component styled according to PSP design.
 * Displays a message with Yes and No buttons.
 * Supports alert mode which turns text blue and shows a red rectangle.
 *
 * @example
 * ```tsx
 * <YesNoDialog
 *   open={isOpen}
 *   onClose={() => setIsOpen(false)}
 *   onConfirm={() => {
 *     console.log("User confirmed");
 *     setIsOpen(false);
 *   }}
 *   title="CMS access warning for patient currently not under hospital level case"
 *   message="You are attempting to access a patient&apos;s record which you might NOT be authorized..."
 *   alert={true}
 * />
 * ```
 */
export function YesNoDialog({
	open,
	onClose,
	onConfirm,
	title,
	message,
	yesButtonText = "Yes",
	noButtonText = "No",
	alert = false,
}: YesNoDialogProps) {
	const handleConfirm = () => {
		onConfirm();
	};

	return (
		<Dialog
			open={open}
			onClose={onClose}
			PaperProps={{
				sx: dialogStyles.paper,
			}}
		>
			{/* Title bar */}
			<Box sx={dialogStyles.title}>
				<Typography sx={dialogStyles.titleText}>{title}</Typography>
			</Box>

			{/* Outer container */}
			<Box sx={dialogStyles.outerContainer}>
				{/* White inner container */}
				<Box
					sx={
						alert
							? dialogStyles.innerContainer
							: dialogStyles.innerContainerNoAlert
					}
				>
					{/* Red alert bar - only shown in alert mode, at the top edge */}
					{alert && <Box sx={dialogStyles.alertBar} />}

					{/* Message content */}
					<Typography
						sx={alert ? dialogStyles.messageAlert : dialogStyles.message}
					>
						{message}
					</Typography>

					{/* Button row */}
					<Box sx={{ display: "flex", justifyContent: "center", gap: 2 }}>
						<Button onClick={handleConfirm} sx={dialogStyles.button}>
							{yesButtonText}
						</Button>
						<Button onClick={onClose} sx={dialogStyles.button}>
							{noButtonText}
						</Button>
					</Box>
				</Box>
			</Box>
		</Dialog>
	);
}
