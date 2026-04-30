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
} from "@mui/material";
import CloseIcon from "@mui/icons-material/Close";

const buttonGreen = "#168065";
const dialogBorderRadius = "4px";
const buttonBorderRadius = "1px";

export interface ChoiceOption {
	/** Unique value for the option */
	value: string;
	/** Display label for the option */
	label: string;
}

export interface ChoiceDialogProps {
	/** Whether the dialog is open */
	open: boolean;
	/** Callback when dialog is closed (Cancel or X clicked) */
	onClose: () => void;
	/** Callback when OK is clicked with the selected value */
	onConfirm: (selectedValue: string) => void;
	/** Dialog title */
	title: string;
	/** Available options to choose from */
	options: ChoiceOption[];
	/** Default selected value (defaults to first option) */
	defaultValue?: string;
	/** Text for the OK button (default: "OK") */
	okButtonText?: string;
	/** Text for the Cancel button (default: "Cancel") */
	cancelButtonText?: string;
}

const dialogStyles = {
	paper: {
		borderRadius: dialogBorderRadius,
		border: "none",
		backgroundColor: "#ffffff",
		boxShadow: "0 4px 24px rgba(0, 0, 0, 0.15)",
		maxWidth: 440,
		width: "100%",
		padding: 0,
		overflow: "hidden",
	},
	header: {
		display: "flex",
		alignItems: "center",
		justifyContent: "space-between",
		padding: "16px 24px 12px",
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
		padding: "0 24px 16px",
	},
	radioLabel: {
		fontSize: "13px",
		fontWeight: 400,
		color: "#333333",
	},
	radio: {
		color: buttonGreen,
		padding: "6px",
		"&.Mui-checked": {
			color: buttonGreen,
		},
		"& .MuiSvgIcon-root": { fontSize: 20 },
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
 * Modern choice dialog with radio button options.
 *
 * @example
 * ```tsx
 * <ChoiceDialog
 *   open={isOpen}
 *   onClose={() => setIsOpen(false)}
 *   onConfirm={(value) => {
 *     console.log("Selected:", value);
 *     setIsOpen(false);
 *   }}
 *   title="Print Choice for Normal Patient List"
 *   options={[
 *     { value: "without-space", label: "Print without in-line space" },
 *     { value: "with-space", label: "Print with in-line space" },
 *   ]}
 *   defaultValue="without-space"
 * />
 * ```
 */
export function ChoiceDialog({
	open,
	onClose,
	onConfirm,
	title,
	options,
	defaultValue,
	okButtonText = "OK",
	cancelButtonText = "Cancel",
}: ChoiceDialogProps) {
	const [selectedValue, setSelectedValue] = useState(
		defaultValue ?? options[0]?.value ?? "",
	);

	const handleConfirm = () => {
		onConfirm(selectedValue);
	};

	const handleChange = (event: React.ChangeEvent<HTMLInputElement>) => {
		setSelectedValue(event.target.value);
	};

	return (
		<Dialog
			open={open}
			onClose={onClose}
			PaperProps={{ sx: dialogStyles.paper }}
		>
			{/* Header: title + close button */}
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

			{/* Radio options */}
			<Box sx={dialogStyles.body}>
				<RadioGroup value={selectedValue} onChange={handleChange}>
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
					onClick={handleConfirm}
					sx={dialogStyles.okButton}
					disableElevation
				>
					{okButtonText}
				</Button>
			</Box>
		</Dialog>
	);
}
