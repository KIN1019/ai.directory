import {
	Box,
	Typography,
	Select,
	MenuItem,
	type SelectChangeEvent,
} from "@mui/material";
import { pspToolbarStyles, pspColors } from "../theme/pspTheme";

/**
 * Custom dropdown caret icon matching PSP design.
 * Renders a simple thin chevron (∨) pointing down.
 */
function DropdownIcon(props: React.SVGProps<SVGSVGElement>) {
	return (
		<svg
			{...props}
			width="12"
			height="8"
			viewBox="0 0 12 8"
			fill="none"
			xmlns="http://www.w3.org/2000/svg"
			style={{ marginRight: 8, ...props.style }}
		>
			<path
				d="M1 1.5L6 6.5L11 1.5"
				stroke="#666666"
				strokeWidth="1.5"
				strokeLinecap="round"
				strokeLinejoin="round"
			/>
		</svg>
	);
}

export interface DropdownOption {
	/** Value used internally for selection */
	value: string;
	/** Display label shown in the dropdown */
	label: string;
}

export interface DropdownProps {
	/** Currently selected value */
	value: string;
	/** Available options */
	options: DropdownOption[];
	/** Callback when selection changes */
	onChange: (value: string) => void;
	/** Label text displayed to the left of the dropdown */
	label?: string;
	/** Whether the dropdown is disabled */
	disabled?: boolean;
	/** Minimum width of the select element (default: "16em") */
	minWidth?: string | number;
	/** Placeholder text when no value is selected */
	placeholder?: string;
	/** Whether to include an "ALL" option at the top */
	includeAllOption?: boolean;
	/** Custom label for the "ALL" option (default: "ALL") */
	allOptionLabel?: string;
	/** Custom value for the "ALL" option (default: "ALL") */
	allOptionValue?: string;
}

/**
 * Reusable dropdown component styled according to PSP design.
 * Supports optional label, "ALL" option, and customizable width.
 *
 * @example
 * ```tsx
 * <Dropdown
 *   label="Modality"
 *   value={selectedModality}
 *   options={[
 *     { value: "intrathecal", label: "Intrathecal" },
 *     { value: "epidural", label: "Epidural Analgesia" },
 *   ]}
 *   onChange={setSelectedModality}
 *   includeAllOption
 * />
 * ```
 */
export function Dropdown({
	value,
	options,
	onChange,
	label,
	disabled = false,
	minWidth = "16em",
	placeholder,
	includeAllOption = false,
	allOptionLabel = "ALL",
	allOptionValue = "ALL",
}: DropdownProps) {
	const handleChange = (event: SelectChangeEvent<string>) => {
		onChange(event.target.value);
	};

	// Build the full options list with optional "ALL" at the top
	const fullOptions: DropdownOption[] = includeAllOption
		? [{ value: allOptionValue, label: allOptionLabel }, ...options]
		: options;

	return (
		<Box sx={{ display: "flex", alignItems: "center", gap: 1 }}>
			{label && (
				<Typography component="span" sx={pspToolbarStyles.label}>
					{label}
				</Typography>
			)}
			<Select
				value={value}
				onChange={handleChange}
				disabled={disabled}
				size="small"
				displayEmpty={!!placeholder}
				IconComponent={DropdownIcon}
				renderValue={(selected) => {
					if (!selected && placeholder) {
						return (
							<Typography sx={{ color: "text.secondary", opacity: 0.7 }}>
								{placeholder}
							</Typography>
						);
					}
					// Find the label for the selected value
					const selectedOption = fullOptions.find(
						(opt) => opt.value === selected,
					);
					return selectedOption?.label ?? selected;
				}}
				sx={{
					...pspToolbarStyles.select,
					minWidth,
					borderRadius: 0,
					"& .MuiSelect-select": {
						borderRadius: 0,
						padding: "4px 28px 4px 8px",
						backgroundColor: disabled ? "#f5f5f5" : "#ffffff",
						color: disabled ? "#999999" : "inherit",
						cursor: disabled ? "default" : "pointer",
						"&:focus": {
							backgroundColor: disabled ? "#f5f5f5" : "#ffffff",
						},
					},
					"& .MuiSelect-icon": {
						top: "50%",
						transform: "translateY(-50%)",
						right: 4,
						opacity: disabled ? 0.5 : 1,
					},
					"&.Mui-disabled": {
						backgroundColor: "#f5f5f5",
						cursor: "default",
						"& .MuiOutlinedInput-notchedOutline": {
							borderColor: "#cccccc",
						},
					},
					"&.Mui-focused": {
						backgroundColor: "#ffffff",
					},
					"&.Mui-focused .MuiOutlinedInput-notchedOutline": {
						borderColor: pspColors.selectBorder,
					},
				}}
				MenuProps={{
					PaperProps: {
						sx: {
							maxHeight: 300,
							borderRadius: 0,
							border: `1px solid ${pspColors.selectBorder}`,
							boxShadow: "2px 2px 4px rgba(0, 0, 0, 0.2)",
							backgroundColor: "#ffffff",
							"& .MuiList-root": {
								padding: 0,
							},
							"& .MuiMenuItem-root": {
								fontFamily: pspColors.fontFamily,
								fontSize: "12px",
								padding: "0 8px",
								height: "2em",
								minHeight: "2em",
								color: "#000000",
								backgroundColor: "#ffffff",
								border: "1px solid transparent",
								"&.Mui-selected": {
									backgroundColor: "#c8daf0",
									color: "#000000",
									border: "1px solid #0066cc",
									"&:hover": {
										backgroundColor: "#b8cce4",
									},
								},
								"&:hover": {
									backgroundColor: "#e8f0f8",
								},
							},
						},
					},
				}}
			>
				{fullOptions.map((option) => (
					<MenuItem key={option.value} value={option.value}>
						{option.label}
					</MenuItem>
				))}
			</Select>
		</Box>
	);
}
