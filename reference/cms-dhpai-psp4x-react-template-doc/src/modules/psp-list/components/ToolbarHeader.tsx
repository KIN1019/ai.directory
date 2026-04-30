import { Box } from "@mui/material";

import { pspToolbarStyles } from "../theme/pspTheme";
import { DatePicker } from "./DatePicker";
import { Dropdown } from "./Dropdown";
import type { DropdownOption } from "./Dropdown";
import { StatBox } from "./StatBox";

export interface ToolbarHeaderProps {
	/** Currently selected ward value */
	selectedWard: string;
	/** Available ward options */
	wardOptions: DropdownOption[];
	/** Callback when ward selection changes */
	onWardChange: (ward: string) => void;
	/** Number of active patients in the selected ward */
	activePatientCount: number;
	/** Number of patients displayed in PSP */
	displayedPatientCount: number;
	/** Whether the ward selector is disabled */
	wardSelectorDisabled?: boolean;
	/** Currently selected modality value */
	selectedModality?: string;
	/** Available modality options */
	modalityOptions?: DropdownOption[];
	/** Callback when modality selection changes */
	onModalityChange?: (modality: string) => void;
	/** Whether the modality selector is disabled */
	modalitySelectorDisabled?: boolean;
	/** Appointment date value */
	appointmentDate?: Date | null;
	/** Callback when appointment date changes */
	onAppointmentDateChange?: (date: Date | null) => void;
	/** Whether the date picker is disabled */
	datePickerDisabled?: boolean;
}

/**
 * Toolbar header component combining ward selector and patient stats.
 * Follows PSP design with ward selector on the left and stats on the right.
 */
export function ToolbarHeader({
	selectedWard,
	wardOptions,
	onWardChange,
	activePatientCount,
	displayedPatientCount,
	wardSelectorDisabled = false,
	selectedModality,
	modalityOptions = [],
	onModalityChange,
	modalitySelectorDisabled = false,
	appointmentDate,
	onAppointmentDateChange,
	datePickerDisabled = false,
}: ToolbarHeaderProps) {
	return (
		<Box sx={pspToolbarStyles.toolbar}>
			<Box sx={{ display: "flex", alignItems: "center", gap: 2 }}>
				{appointmentDate !== undefined && onAppointmentDateChange && (
					<DatePicker
						label="Appointment Date"
						value={appointmentDate}
						onChange={onAppointmentDateChange}
						disabled={datePickerDisabled}
					/>
				)}
				<Dropdown
					label="Ward"
					value={selectedWard}
					options={wardOptions}
					onChange={onWardChange}
					disabled={wardSelectorDisabled}
				/>
				{modalityOptions.length > 0 &&
					selectedModality !== undefined &&
					onModalityChange && (
						<Dropdown
							label="Modality"
							value={selectedModality}
							options={modalityOptions}
							onChange={onModalityChange}
							disabled={modalitySelectorDisabled}
						/>
					)}
			</Box>
			<Box sx={pspToolbarStyles.toolbarRight}>
				<StatBox label="Active patient in ward" value={activePatientCount} />
				<StatBox
					label="Patient displayed in PSP"
					value={displayedPatientCount}
				/>
			</Box>
		</Box>
	);
}
