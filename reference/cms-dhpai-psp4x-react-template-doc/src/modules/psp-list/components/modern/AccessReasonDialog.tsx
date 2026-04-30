import { useState } from "react";
import {
	Dialog,
	Button,
	Box,
	Typography,
	IconButton,
	Radio,
	RadioGroup,
	FormControlLabel,
	TextField,
} from "@mui/material";
import CloseIcon from "@mui/icons-material/Close";

const buttonGreen = "#168065";
const dialogBorderRadius = "4px";
const buttonBorderRadius = "1px";

export interface AccessReasonOption {
	/** Unique value for the option */
	value: string;
	/** Display label for the option */
	label: string;
	/** Description text shown on the right side */
	detailDescription: string;
}

export interface AccessReasonDialogProps {
	/** Whether the dialog is open */
	open: boolean;
	/** Callback when dialog is closed (Cancel or X clicked) */
	onClose: () => void;
	/** Callback when Save is clicked with the selected reason and details */
	onSave: (selectedReason: string, details: string) => void;
	/** Dialog title */
	title: string;
	/** Available reason options to choose from */
	options: AccessReasonOption[];
	/** Warning text displayed in red above the text area */
	warningText: string;
	/** Text for the Save button (default: "Save") */
	saveButtonText?: string;
	/** Text for the Cancel button (default: "Cancel") */
	cancelButtonText?: string;
}

const dialogStyles = {
	paper: {
		borderRadius: dialogBorderRadius,
		border: "none",
		backgroundColor: "#ffffff",
		boxShadow: "0 4px 24px rgba(0, 0, 0, 0.15)",
		maxWidth: 680,
		width: "100%",
		padding: 0,
		overflow: "hidden",
	},
	header: {
		display: "flex",
		alignItems: "center",
		justifyContent: "space-between",
		padding: "16px 24px 8px",
	},
	title: {
		fontSize: "14px",
		fontWeight: 700,
		color: "#1a1a1a",
		lineHeight: 1.5,
	},
	closeButton: {
		padding: "4px",
		color: "#666666",
		"&:hover": {
			backgroundColor: "rgba(0, 0, 0, 0.04)",
		},
	},
	body: {
		padding: "0 24px 20px",
	},
	columnsContainer: {
		display: "flex",
		gap: 0,
		marginBottom: "16px",
	},
	leftColumn: {
		flex: "0 0 auto",
		paddingRight: "16px",
	},
	rightColumn: {
		flex: 1,
		paddingLeft: "16px",
		borderLeft: "1px solid #e0e0e0",
	},
	detailsHeader: {
		fontSize: "13px",
		fontWeight: 700,
		color: "#333333",
		marginBottom: "8px",
	},
	detailsText: {
		fontSize: "13px",
		fontWeight: 400,
		color: "#555555",
		lineHeight: 1.6,
	},
	radio: {
		color: buttonGreen,
		padding: "4px 6px",
		"&.Mui-checked": {
			color: buttonGreen,
		},
		"& .MuiSvgIcon-root": { fontSize: 20 },
	},
	radioLabel: {
		fontSize: "13px",
		fontWeight: 400,
		color: "#333333",
	},
	warningText: {
		fontSize: "13px",
		fontWeight: 400,
		color: "#d32f2f",
		lineHeight: 1.5,
		marginBottom: "8px",
	},
	textField: {
		"& .MuiOutlinedInput-root": {
			fontSize: "13px",
			borderRadius: "2px",
			"& fieldset": {
				borderColor: "#cccccc",
			},
			"&:hover fieldset": {
				borderColor: "#999999",
			},
			"&.Mui-focused fieldset": {
				borderColor: buttonGreen,
			},
		},
	},
	buttonRow: {
		display: "flex",
		justifyContent: "flex-end",
		gap: "12px",
		padding: "12px 24px",
		backgroundColor: "#f5f5f5",
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
	saveButton: {
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
		"&.Mui-disabled": {
			backgroundColor: "#a0c4b8",
			color: "#ffffff",
		},
	},
} as const;

/**
 * Modern access reason dialog.
 * Displays radio options with detail descriptions, a warning, and a text area.
 *
 * @example
 * ```tsx
 * <AccessReasonDialog
 *   open={isOpen}
 *   onClose={() => setIsOpen(false)}
 *   onSave={(reason, details) => {
 *     console.log("Reason:", reason, "Details:", details);
 *     setIsOpen(false);
 *   }}
 *   title="Print Choice for Normal Patient List"
 *   options={accessReasonOptions}
 *   warningText="Please provide sufficient details..."
 * />
 * ```
 */
export function AccessReasonDialog({
	open,
	onClose,
	onSave,
	title,
	options,
	warningText,
	saveButtonText = "Save",
	cancelButtonText = "Cancel",
}: AccessReasonDialogProps) {
	const [selectedReason, setSelectedReason] = useState(options[0]?.value ?? "");
	const [details, setDetails] = useState("");

	const handleSave = () => {
		onSave(selectedReason, details);
	};

	const handleReasonChange = (event: React.ChangeEvent<HTMLInputElement>) => {
		setSelectedReason(event.target.value);
		setDetails("");
	};

	// Build the combined detail descriptions text
	const detailDescriptions = options
		.map((opt) => opt.detailDescription)
		.join(" ");

	return (
		<Dialog
			open={open}
			onClose={onClose}
			PaperProps={{ sx: dialogStyles.paper }}
		>
			{/* Header */}
			<Box sx={dialogStyles.header}>
				<Typography sx={dialogStyles.title}>{title}</Typography>
				<IconButton
					onClick={onClose}
					sx={dialogStyles.closeButton}
					size="small"
				>
					<CloseIcon fontSize="small" />
				</IconButton>
			</Box>

			{/* Body */}
			<Box sx={dialogStyles.body}>
				{/* Two-column layout: radios on left, details on right */}
				<Box sx={dialogStyles.columnsContainer}>
					<Box sx={dialogStyles.leftColumn}>
						<RadioGroup value={selectedReason} onChange={handleReasonChange}>
							{options.map((option) => (
								<FormControlLabel
									key={option.value}
									value={option.value}
									control={<Radio size="small" sx={dialogStyles.radio} />}
									label={option.label}
									sx={{
										margin: 0,
										"& .MuiFormControlLabel-label": dialogStyles.radioLabel,
									}}
								/>
							))}
						</RadioGroup>
					</Box>

					<Box sx={dialogStyles.rightColumn}>
						<Typography sx={dialogStyles.detailsHeader}>
							Please provide details on:
						</Typography>
						<Typography sx={dialogStyles.detailsText}>
							{detailDescriptions}
						</Typography>
					</Box>
				</Box>

				{/* Warning text */}
				<Typography sx={dialogStyles.warningText}>{warningText}</Typography>

				{/* Text area */}
				<TextField
					fullWidth
					multiline
					rows={4}
					value={details}
					onChange={(e) => setDetails(e.target.value)}
					placeholder=""
					sx={dialogStyles.textField}
				/>
			</Box>

			{/* Button row */}
			<Box sx={dialogStyles.buttonRow}>
				<Button
					variant="outlined"
					onClick={onClose}
					sx={dialogStyles.cancelButton}
				>
					{cancelButtonText}
				</Button>
				<Button
					variant="contained"
					onClick={handleSave}
					sx={dialogStyles.saveButton}
					disableElevation
					disabled={!selectedReason || !details.trim()}
				>
					{saveButtonText}
				</Button>
			</Box>
		</Dialog>
	);
}
