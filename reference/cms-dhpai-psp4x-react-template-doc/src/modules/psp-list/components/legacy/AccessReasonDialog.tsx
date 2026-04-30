import { useState } from "react";
import {
	Dialog,
	Button,
	Box,
	Typography,
	Radio,
	RadioGroup,
	FormControlLabel,
	TextField,
} from "@mui/material";

import { pspColors } from "../../theme/pspTheme";

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
	/** Callback when dialog is closed (Cancel clicked) */
	onClose: () => void;
	/** Callback when Save is clicked with the selected reason and details */
	onSave: (selectedReason: string, details: string) => void;
	/** Dialog title displayed in the header */
	title: string;
	/** Instruction text above the options */
	instructionText: string;
	/** Available reason options to choose from */
	options: AccessReasonOption[];
	/** Warning text displayed at the bottom in red */
	warningText: string;
	/** Text for the Save button (default: "Save") */
	saveButtonText?: string;
	/** Text for the Cancel button (default: "Cancel") */
	cancelButtonText?: string;
}

const dialogStyles = {
	paper: {
		borderRadius: "3px",
		border: `1px solid ${pspColors.tableBorder}`,
		boxShadow: "4px 4px 8px rgba(0, 0, 0, 0.3)",
		minWidth: 520,
		maxWidth: 600,
		overflow: "hidden",
	},
	// Title bar - gradient lighter on top (light from above)
	title: {
		display: "flex",
		alignItems: "center",
		justifyContent: "space-between",
		padding: "0 4px",
		background: "linear-gradient(to bottom, #e9e9e9 0%, #d6d6d6 100%)",
		minHeight: 18,
		borderBottom: "1px solid #c0c0c0",
	},
	titleText: {
		fontFamily: pspColors.fontFamily,
		fontSize: "10px",
		fontWeight: 700,
		color: "#444444",
		lineHeight: 1,
	},
	// Outer container
	outerContainer: {
		background: "linear-gradient(to bottom, #e9e9e9 0%, #f5f5f5 100%)",
		padding: "4px",
	},
	// White inner content box
	innerContainer: {
		backgroundColor: "#ffffff",
		borderRadius: "2px",
		border: `1px solid ${pspColors.tableBorder}`,
		padding: "0",
	},
	// Instruction text row with gradient (lighter on top)
	instructionRow: {
		background: "linear-gradient(to bottom, #e9e9e9 0%, #d6d6d6 100%)",
		padding: "4px 8px",
		borderBottom: `1px solid ${pspColors.tableBorder}`,
	},
	instructionText: {
		fontFamily: pspColors.fontFamily,
		fontSize: "11px",
		fontWeight: 700,
		color: "#444444",
	},
	// Column header row with gradient (lighter on top)
	headerRow: {
		display: "flex",
		background: "linear-gradient(to bottom, #e9e9e9 0%, #d6d6d6 100%)",
		borderTop: "1px solid #ffffff",
		borderBottom: `1px solid ${pspColors.tableBorder}`,
	},
	// Column header text
	columnHeader: {
		fontFamily: pspColors.fontFamily,
		fontSize: "11px",
		fontWeight: 700,
		color: "#444444",
		padding: "4px 8px",
	},
	// Left column in header
	headerLeftColumn: {
		flex: "0 0 220px",
		borderRight: `1px solid ${pspColors.tableBorder}`,
	},
	// Right column in header
	headerRightColumn: {
		flex: 1,
	},
	// Content rows container
	contentRows: {
		display: "flex",
		flexDirection: "column" as const,
	},
	// Each option row - no inner borders between rows
	optionRow: {
		display: "flex",
		alignItems: "center",
	},
	// Left column in content
	contentLeftColumn: {
		flex: "0 0 220px",
		borderRight: `1px solid ${pspColors.tableBorder}`,
		padding: "0",
	},
	// Right column in content
	contentRightColumn: {
		flex: 1,
		padding: "0",
		display: "flex",
		alignItems: "center",
	},
	// Radio label styling
	radioLabel: {
		fontFamily: pspColors.fontFamily,
		fontSize: "13px",
		fontWeight: 400,
		color: "#2f37ff",
	},
	// Detail description text (right column)
	detailDescription: {
		fontFamily: pspColors.fontFamily,
		fontSize: "13px",
		fontWeight: 400,
		color: "#2f37ff",
	},
	// Warning section - no border, no padding
	warningSection: {
		padding: "0",
		margin: "0",
	},
	// Warning text in red
	warningText: {
		fontFamily: pspColors.fontFamily,
		fontSize: "13px",
		fontWeight: 400,
		color: "#ff0000",
	},
	// Text field styling
	textField: {
		"& .MuiInputBase-root": {
			fontFamily: pspColors.fontFamily,
			fontSize: "11px",
			backgroundColor: "#ffffff",
			border: `1px solid ${pspColors.tableBorder}`,
			borderRadius: "2px",
		},
		"& .MuiInputBase-input": {
			padding: "8px",
		},
		"& .MuiOutlinedInput-notchedOutline": {
			border: "none",
		},
	},
	// 3D button style - less padding top/bottom
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
		lineHeight: 1.4,
		"&:hover": {
			background:
				"linear-gradient(to bottom, #ffffff 0%, #ffffff 40%, #d0d0d0 100%)",
		},
		"&.Mui-disabled": {
			background:
				"linear-gradient(to bottom, #fbfbfb 0%, #ffffff 40%, #c7c7c7 100%)",
			color: "#999999",
			border: "1px solid #9e9e9e",
		},
	},
} as const;

/**
 * Access reason dialog component styled according to PSP design.
 * Displays radio button options with dashed lines connecting to detail descriptions.
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
 *   title="CMS access purpose for patient currently not under hospital level case"
 *   instructionText="If yes, please identify one of the following access reasons and provide detail:"
 *   options={accessReasonOptions}
 *   warningText="Please provide sufficient details for access reason..."
 * />
 * ```
 */
export function AccessReasonDialog({
	open,
	onClose,
	onSave,
	title,
	instructionText,
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
		setDetails(""); // Clear details when reason changes
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
					{/* Instruction text with gradient */}
					<Box sx={dialogStyles.instructionRow}>
						<Typography sx={dialogStyles.instructionText}>
							{instructionText}
						</Typography>
					</Box>

					{/* Table with header and content */}
					<Box sx={{ borderBottom: `1px solid ${pspColors.tableBorder}` }}>
						{/* Column headers with gradient */}
						<Box sx={dialogStyles.headerRow}>
							<Box sx={dialogStyles.headerLeftColumn}>
								<Typography sx={dialogStyles.columnHeader}>Reason</Typography>
							</Box>
							<Box sx={dialogStyles.headerRightColumn}>
								<Typography sx={dialogStyles.columnHeader}>
									Please provide details on:
								</Typography>
							</Box>
						</Box>

						{/* Radio options rows */}
						<RadioGroup value={selectedReason} onChange={handleReasonChange}>
							<Box sx={dialogStyles.contentRows}>
								{options.map((option) => (
									<Box key={option.value} sx={dialogStyles.optionRow}>
										{/* Left column - Radio button with dashed extension */}
										<Box
											sx={{
												...dialogStyles.contentLeftColumn,
												display: "flex",
												alignItems: "center",
											}}
										>
											<FormControlLabel
												value={option.value}
												control={
													<Radio
														size="small"
														sx={{
															padding: "2px 4px",
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
													"& .MuiFormControlLabel-label":
														dialogStyles.radioLabel,
												}}
											/>
											{/* Dashed line extending to border */}
											<Box
												sx={{
													flex: 1,
													borderBottom: "1.5px dashed #000000",
													marginLeft: "4px",
													marginRight: "4px",
												}}
											/>
										</Box>

										{/* Right column - Detail description */}
										<Box sx={dialogStyles.contentRightColumn}>
											<Typography
												sx={{ ...dialogStyles.detailDescription, pl: 1 }}
											>
												{option.detailDescription}
											</Typography>
										</Box>
									</Box>
								))}
							</Box>
						</RadioGroup>
					</Box>

					{/* Warning section - no border */}
					<Box sx={dialogStyles.warningSection}>
						<Typography sx={dialogStyles.warningText}>{warningText}</Typography>
					</Box>

					{/* Text area for details */}
					<TextField
						fullWidth
						multiline
						rows={3}
						value={details}
						onChange={(e) => setDetails(e.target.value)}
						sx={{ ...dialogStyles.textField, mb: 1 }}
					/>

					{/* Button row */}
					<Box
						sx={{ display: "flex", justifyContent: "center", gap: 2, py: 0.5 }}
					>
						<Button
							onClick={handleSave}
							sx={dialogStyles.button}
							disabled={!selectedReason || !details.trim()}
						>
							{saveButtonText}
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
