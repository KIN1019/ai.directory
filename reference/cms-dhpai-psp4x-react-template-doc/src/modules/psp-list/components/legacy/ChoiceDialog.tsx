import { useState } from "react";
import {
	Dialog,
	Button,
	Box,
	Typography,
	Radio,
	RadioGroup,
	FormControlLabel,
} from "@mui/material";

import { pspColors } from "../../theme/pspTheme";

export interface ChoiceOption {
	/** Unique value for the option */
	value: string;
	/** Display label for the option */
	label: string;
}

export interface ChoiceDialogProps {
	/** Whether the dialog is open */
	open: boolean;
	/** Callback when dialog is closed (Cancel clicked) */
	onClose: () => void;
	/** Callback when OK is clicked with the selected value */
	onConfirm: (selectedValue: string) => void;
	/** Dialog title displayed in the header */
	title: string;
	/** Label for the choice group/fieldset */
	groupLabel: string;
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
		padding: "12px",
	},
	// Fieldset styling
	fieldset: {
		border: `1px solid ${pspColors.tableBorder}`,
		borderRadius: "2px",
		padding: "8px 12px",
		paddingBottom: "50px",
		margin: 0,
	},
	legend: {
		fontFamily: pspColors.fontFamily,
		fontSize: "11px",
		fontWeight: 700,
		color: "#000000",
		padding: "0 4px",
	},
	// Radio label styling
	radioLabel: {
		fontFamily: pspColors.fontFamily,
		fontSize: "11px",
		fontWeight: 700,
		color: "#000000",
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
 * Choice dialog component styled according to PSP design.
 * Displays a group of radio button choices with OK and Cancel buttons.
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
 *   groupLabel="Print Choice"
 *   options={[
 *     { value: "without-space", label: "Print without in-line space:" },
 *     { value: "with-space", label: "Print with in-line space:" },
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
	groupLabel,
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
				<Box sx={dialogStyles.innerContainer}>
					{/* Fieldset with radio options */}
					<Box component="fieldset" sx={dialogStyles.fieldset}>
						<Typography component="legend" sx={dialogStyles.legend}>
							{groupLabel}
						</Typography>
						<RadioGroup value={selectedValue} onChange={handleChange}>
							{options.map((option) => (
								<FormControlLabel
									key={option.value}
									value={option.value}
									control={
										<Radio
											size="small"
											sx={{
												padding: "2px 8px",
												color: "#0174fe",
												"&.Mui-checked": {
													color: "#0174fe",
												},
												"& .MuiSvgIcon-root": { fontSize: 16 },
											}}
										/>
									}
									label={option.label}
									sx={{
										margin: 0,
										"& .MuiFormControlLabel-label": dialogStyles.radioLabel,
									}}
									labelPlacement="start"
								/>
							))}
						</RadioGroup>
					</Box>

					{/* Button row */}
					<Box
						sx={{ display: "flex", justifyContent: "center", gap: 2, mt: 3 }}
					>
						<Button onClick={handleConfirm} sx={dialogStyles.button}>
							{okButtonText}
						</Button>
						<Button onClick={onClose} sx={dialogStyles.button}>
							{cancelButtonText}
						</Button>
					</Box>
				</Box>
			</Box>
		</Dialog>
	);
}
