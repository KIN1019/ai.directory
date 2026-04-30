import { Dialog, Button, Box, Typography } from "@mui/material";
import PrintIcon from "@mui/icons-material/Print";

import { pspColors } from "../../theme/pspTheme";

/**
 * Custom warning triangle icon matching PSP design.
 * Yellow/orange gradient filled triangle with black exclamation mark.
 */
function WarningTriangleIcon({ size = 40 }: { size?: number }) {
	const gradientId = "warningTriangleGradient";
	return (
		<svg
			width={size}
			height={size}
			viewBox="0 0 48 48"
			fill="none"
			xmlns="http://www.w3.org/2000/svg"
			style={{ flexShrink: 0 }}
		>
			<defs>
				<linearGradient id={gradientId} x1="0%" y1="0%" x2="0%" y2="100%">
					<stop offset="0%" stopColor="#ffe9e0" />
					<stop offset="100%" stopColor="#e9b537" />
				</linearGradient>
			</defs>
			{/* Triangle with rounded top spike */}
			<path
				d="M24 6 Q24 4 25.5 7 L44 40 Q46 44 42 44 H6 Q2 44 4 40 L22.5 7 Q24 4 24 6 Z"
				fill={`url(#${gradientId})`}
				stroke="#000000"
				strokeWidth="2.5"
				strokeLinejoin="round"
			/>
			{/* Thicker exclamation mark - rounded rect */}
			<rect x="21" y="15" width="6" height="16" rx="2" fill="#000000" />
			{/* Circle at bottom of exclamation */}
			<circle cx="24" cy="37" r="3.5" fill="#000000" />
		</svg>
	);
}

export interface WarningDialogProps {
	/** Whether the dialog is open */
	open: boolean;
	/** Callback when dialog is closed */
	onClose: () => void;
	/** Dialog title displayed in the header (e.g., "Warning (1-6400-23-W-015)") */
	title: string;
	/** Main description message displayed in the DESCRIPTION section */
	description: string;
	/** Action text displayed in the ACTION section */
	action: string;
	/** Callback when Print Message button is clicked (optional) */
	onPrint?: () => void;
	/** Text for the OK button (default: "OK") */
	okButtonText?: string;
}

const dialogStyles = {
	paper: {
		borderRadius: "3px",
		border: `1px solid ${pspColors.tableBorder}`,
		boxShadow: "4px 4px 8px rgba(0, 0, 0, 0.3)",
		minWidth: 450,
		maxWidth: 550,
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
		padding: "12px",
	},
	// 3D button style - gray gradient (peaks in middle)
	printButton: {
		fontFamily: pspColors.fontFamily,
		fontSize: "11px",
		fontWeight: 700,
		textTransform: "none" as const,
		background:
			"linear-gradient(to bottom, #fbfbfb 0%, #ffffff 40%, #c7c7c7 100%)",
		border: "1px solid #9e9e9e",
		borderRadius: "9999px",
		padding: "0 12px",
		color: "#000000",
		minWidth: "auto",
		minHeight: "auto",
		lineHeight: 1.6,
		"&:hover": {
			background:
				"linear-gradient(to bottom, #ffffff 0%, #ffffff 40%, #d0d0d0 100%)",
		},
	},
	// 3D button style - blue gradient (peaks in middle)
	okButton: {
		fontFamily: pspColors.fontFamily,
		fontSize: "11px",
		fontWeight: 700,
		textTransform: "none" as const,
		background:
			"linear-gradient(to bottom, #fbfbfb 0%, #ffffff 40%, #8cd2f0 100%)",
		border: "1px solid #9e9e9e",
		borderRadius: "9999px",
		padding: "0 24px",
		color: "#000000",
		minWidth: 80,
		minHeight: "auto",
		lineHeight: 1.6,
		"&:hover": {
			background:
				"linear-gradient(to bottom, #ffffff 0%, #ffffff 40%, #a0daf5 100%)",
		},
	},
	sectionLabel: {
		fontFamily: pspColors.fontFamily,
		fontSize: "12px",
		fontWeight: 700,
		color: "#000000",
		margin: 0,
		padding: 0,
		lineHeight: 1.2,
	},
	descriptionBox: {
		backgroundColor: "#ffffff",
		border: `1px solid ${pspColors.tableBorder}`,
		minHeight: "9em",
		maxHeight: "10em",
		overflow: "auto",
		padding: "1px",
	},
	descriptionText: {
		fontFamily: pspColors.fontFamily,
		fontSize: "12px",
		color: "#000000",
		lineHeight: 1.4,
	},
	actionBox: {
		backgroundColor: "#ffffff",
		border: `1px solid ${pspColors.tableBorder}`,
		minHeight: "9em",
		maxHeight: "10em",
		overflow: "auto",
		padding: "1px",
	},
	actionText: {
		fontFamily: pspColors.fontFamily,
		fontSize: "12px",
		color: "#000000",
		lineHeight: 1.4,
	},
} as const;

/**
 * Warning dialog component styled according to PSP design.
 * Displays a warning with description and action sections.
 *
 * @example
 * ```tsx
 * <WarningDialog
 *   open={isOpen}
 *   onClose={() => setIsOpen(false)}
 *   title="Warning (1-6400-23-W-015)"
 *   description="More than one patient with this name ACT SHEUNG, KIN HONG is found on the patient list"
 *   action="Check on the patient's particulars to confirm the selected patient before proceed"
 *   onPrint={() => window.print()}
 * />
 * ```
 */
export function WarningDialog({
	open,
	onClose,
	title,
	description,
	action,
	onPrint,
	okButtonText = "OK",
}: WarningDialogProps) {
	const handlePrint = () => {
		if (onPrint) {
			onPrint();
		} else {
			window.print();
		}
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

			{/* Translucent outer container */}
			<Box sx={dialogStyles.outerContainer}>
				{/* White inner container */}
				<Box sx={dialogStyles.innerContainer}>
					{/* Print button row */}
					<Box sx={{ display: "flex", justifyContent: "flex-end", mb: 1.5 }}>
						<Button
							onClick={handlePrint}
							sx={dialogStyles.printButton}
							startIcon={<PrintIcon sx={{ fontSize: "4px" }} />}
						>
							Print Message
						</Button>
					</Box>

					{/* Description section - icon on left of both title and content */}
					<Box sx={{ display: "flex", gap: 1.5, mb: "1px" }}>
						<WarningTriangleIcon size={40} />
						<Box sx={{ flex: 1 }}>
							<Typography sx={dialogStyles.sectionLabel}>
								DESCRIPTION
							</Typography>
							<Box sx={dialogStyles.descriptionBox}>
								<Typography sx={dialogStyles.descriptionText}>
									{description}
								</Typography>
							</Box>
						</Box>
					</Box>

					{/* Action section - aligned with description content */}
					<Box sx={{ display: "flex", gap: 1.5 }}>
						{/* Spacer to align with description content */}
						<Box sx={{ width: 40, flexShrink: 0 }} />
						<Box sx={{ flex: 1 }}>
							<Typography sx={dialogStyles.sectionLabel}>ACTION</Typography>
							<Box sx={dialogStyles.actionBox}>
								<Typography sx={dialogStyles.actionText}>{action}</Typography>
							</Box>
						</Box>
					</Box>

					{/* OK button row */}
					<Box sx={{ display: "flex", justifyContent: "flex-end", mt: 1.5 }}>
						<Button onClick={onClose} sx={dialogStyles.okButton}>
							{okButtonText}
						</Button>
					</Box>
				</Box>
			</Box>
		</Dialog>
	);
}
