import { useState, useCallback, useMemo } from "react";
import { Box, Button } from "@mui/material";
import { ThemeProvider } from "@mui/material/styles";
import { DataGridPro } from "@mui/x-data-grid-pro";

import { pspTheme, pspColors } from "./theme/pspTheme";
import {
	DataGridSplit,
	ToolbarHeader,
	WarningDialog,
	ChoiceDialog,
	YesNoDialog,
	AccessReasonDialog,
	ModernWarningDialog,
	ModernChoiceDialog,
	ModernYesNoDialog,
	ModernAccessReasonDialog,
} from "./components";
import type {
	DropdownOption,
	ContextMenuItem,
	AccessReasonOption,
	ModernAccessReasonOption,
} from "./components";
import { dischargeColumns, dummyPatients, HONG_KONG_HOSPITALS } from "./data";
import type { PatientGridRow } from "./types";
import {
	DEFAULT_ROW_HEIGHT,
	DEFAULT_COLUMN_HEADER_HEIGHT,
} from "./utils/constants";

// Convert hospitals to context menu items
const HOSPITAL_MENU_ITEMS: ContextMenuItem[] = HONG_KONG_HOSPITALS.map((h) => ({
	id: h.code,
	label: h.name,
}));

// Default hospital
const DEFAULT_HOSPITAL = "QMH";

// Sample ward options - in a real app, these would come from an API
const WARD_OPTIONS: DropdownOption[] = [
	{ value: "ALL", label: "All Wards" },
	{ value: "5A", label: "5A" },
	{ value: "5B", label: "5B" },
	{ value: "6A", label: "6A" },
	{ value: "6B", label: "6B" },
	{ value: "7A", label: "7A" },
	{ value: "7B", label: "7B" },
	{ value: "AE01", label: "AE01" },
];

// Sample modality options - demonstrating disabled dropdown
const MODALITY_OPTIONS: DropdownOption[] = [
	{ value: "ALL", label: "All Modalities" },
	{ value: "intrathecal", label: "Intrathecal" },
	{ value: "epidural", label: "Epidural Analgesia" },
	{ value: "pca", label: "PCA" },
];

// Default values
const DEFAULT_WARD = WARD_OPTIONS[0].value;
const DEFAULT_MODALITY = MODALITY_OPTIONS[0].value;

// Access reason options
const ACCESS_REASON_OPTIONS: AccessReasonOption[] = [
	{
		value: "patient-care",
		label: "Patient Care / Referral",
		detailDescription: "Referral source or details on patient care",
	},
	{
		value: "medical-report",
		label: "Request of Medical Report",
		detailDescription: "Reference / application number",
	},
	{
		value: "data-access",
		label: "Data access request under PDPO",
		detailDescription: "Reference / application number",
	},
	{
		value: "research",
		label: "Research / study / audit approved by HA",
		detailDescription: "Title of research / study / audit",
	},
	{
		value: "legal",
		label: "Legal / Police / ICAC request",
		detailDescription: "Reference / application number",
	},
	{
		value: "outbreak",
		label: "Outbreak Control",
		detailDescription: "Diagnosis / name of microorganism",
	},
	{
		value: "others",
		label: "Others",
		detailDescription: "Specific reason or fact",
	},
];

// Modern access reason options (same data, modern type)
const MODERN_ACCESS_REASON_OPTIONS: ModernAccessReasonOption[] =
	ACCESS_REASON_OPTIONS;

/**
 * Filters dummy patients by ward code.
 */
function filterPatientsByWard(
	patients: PatientGridRow[],
	ward: string,
): PatientGridRow[] {
	if (ward === "ALL") return patients;
	return patients.filter((p) => p.wardCode === ward);
}

export function PspList() {
	const [selectedWard, setSelectedWard] = useState(DEFAULT_WARD);
	const [selectedModality, setSelectedModality] = useState(DEFAULT_MODALITY);
	const [selectedHospital, setSelectedHospital] = useState(DEFAULT_HOSPITAL);
	const [appointmentDate, setAppointmentDate] = useState<Date | null>(
		new Date(),
	);
	const [warningDialogOpen, setWarningDialogOpen] = useState(false);
	const [choiceDialogOpen, setChoiceDialogOpen] = useState(false);
	const [yesNoAlertDialogOpen, setYesNoAlertDialogOpen] = useState(false);
	const [accessReasonDialogOpen, setAccessReasonDialogOpen] = useState(false);
	const [modernWarningDialogOpen, setModernWarningDialogOpen] = useState(false);
	const [modernChoiceDialogOpen, setModernChoiceDialogOpen] = useState(false);
	const [modernYesNoDialogOpen, setModernYesNoDialogOpen] = useState(false);
	const [modernAccessReasonDialogOpen, setModernAccessReasonDialogOpen] =
		useState(false);

	const patients = useMemo(
		() => filterPatientsByWard(dummyPatients, selectedWard),
		[selectedWard],
	);

	const handleWardChange = useCallback((ward: string) => {
		setSelectedWard(ward);
	}, []);

	const handleModalityChange = useCallback((modality: string) => {
		setSelectedModality(modality);
	}, []);

	const handleHospitalSelect = useCallback((item: ContextMenuItem) => {
		setSelectedHospital(item.id);
		// In a real app, this would trigger data fetching for the selected hospital
		console.log("Selected hospital:", item.id, item.label);
	}, []);

	// Context menu configuration for hospital selection
	const contextMenuConfig = useMemo(
		() => ({
			items: HOSPITAL_MENU_ITEMS,
			selectedId: selectedHospital,
			onSelect: handleHospitalSelect,
		}),
		[selectedHospital, handleHospitalSelect],
	);

	return (
		<ThemeProvider theme={pspTheme}>
			<Box
				sx={{
					padding: "0 1em",
					backgroundColor: pspColors.outerBackground,
					display: "flex",
					flexDirection: "column",
					height: "100%",
				}}
			>
				<ToolbarHeader
					selectedWard={selectedWard}
					wardOptions={WARD_OPTIONS}
					onWardChange={handleWardChange}
					activePatientCount={dummyPatients.length}
					displayedPatientCount={patients.length}
					wardSelectorDisabled={false}
					selectedModality={selectedModality}
					modalityOptions={MODALITY_OPTIONS}
					onModalityChange={handleModalityChange}
					modalitySelectorDisabled={true}
					appointmentDate={appointmentDate}
					onAppointmentDateChange={setAppointmentDate}
				/>

				<Box sx={{ display: "flex", gap: 1, mb: 1 }}>
					<Button
						variant="outlined"
						size="small"
						onClick={() => setWarningDialogOpen(true)}
					>
						Show Warning Dialog
					</Button>
					<Button
						variant="outlined"
						size="small"
						onClick={() => setChoiceDialogOpen(true)}
					>
						Show Choice Dialog
					</Button>
					<Button
						variant="outlined"
						size="small"
						onClick={() => setYesNoAlertDialogOpen(true)}
					>
						Show Yes/No Alert Dialog
					</Button>
					<Button
						variant="outlined"
						size="small"
						onClick={() => setAccessReasonDialogOpen(true)}
					>
						Show Access Reason Dialog
					</Button>
					<Button
						variant="outlined"
						size="small"
						onClick={() => setModernWarningDialogOpen(true)}
					>
						Show Modern Warning Dialog
					</Button>
					<Button
						variant="outlined"
						size="small"
						onClick={() => setModernChoiceDialogOpen(true)}
					>
						Show Modern Choice Dialog
					</Button>
					<Button
						variant="outlined"
						size="small"
						onClick={() => setModernYesNoDialogOpen(true)}
					>
						Show Modern Yes/No Dialog
					</Button>
					<Button
						variant="outlined"
						size="small"
						onClick={() => setModernAccessReasonDialogOpen(true)}
					>
						Show Modern Access Reason Dialog
					</Button>
				</Box>

				<Box
					sx={{
						flex: 1,
						height: "100%",
						width: "100%",
						"& .highlight-cell": {
							color: pspColors.cellTextHighlight,
						},
						"& .uppercase-cell": {
							textTransform: "uppercase",
						},
					}}
				>
					<DataGridSplit
						gridComponent={DataGridPro}
						rows={patients}
						columns={dischargeColumns}
						splitPanels={[
							{
								fields: ["bedNo", "wardCode", "sexAge", "chineseName", "name"],
							},
						]}
						rowHeight={DEFAULT_ROW_HEIGHT}
						columnHeaderHeight={DEFAULT_COLUMN_HEADER_HEIGHT}
						disableColumnMenu
						contextMenuConfig={contextMenuConfig}
					/>
				</Box>

				<WarningDialog
					open={warningDialogOpen}
					onClose={() => setWarningDialogOpen(false)}
					title="Warning (1-6400-23-W-015)"
					description="More than one patient with this name ACT SHEUNG, KIN HONG is found on the patient list"
					action="Check on the patient's particulars to confirm the selected patient before proceed"
				/>

				<ChoiceDialog
					open={choiceDialogOpen}
					onClose={() => setChoiceDialogOpen(false)}
					onConfirm={(value) => {
						console.log("Selected:", value);
						setChoiceDialogOpen(false);
					}}
					title="Print Choice for Normal Patient List"
					groupLabel="Print Choice"
					options={[
						{ value: "without-space", label: "Print without in-line space:" },
						{ value: "with-space", label: "Print with in-line space:" },
					]}
					defaultValue="without-space"
				/>

				<YesNoDialog
					open={yesNoAlertDialogOpen}
					onClose={() => setYesNoAlertDialogOpen(false)}
					onConfirm={() => {
						console.log("User confirmed (alert)");
						setYesNoAlertDialogOpen(false);
					}}
					title="CMS access warning for patient currently not under hospital level case"
					message={
						<>
							You are attempting to access a patient&apos;s record which you
							might NOT be authorized. You are required to give full details of
							the supporting reasons for accessing this record.
							<br />
							<br />
							Your access will be logged and subject to vigilant auditing. Do
							you wish to continue?
						</>
					}
					alert
				/>

				<ModernWarningDialog
					open={modernWarningDialogOpen}
					onClose={() => setModernWarningDialogOpen(false)}
					onConfirm={() => {
						console.log("Modern warning confirmed");
						setModernWarningDialogOpen(false);
					}}
					title='More than one patient with this name "LAM MEI CHEN" is found on the patient list.'
					description="Check on the patient's particulars to confirm the selected patient before proceed"
				/>

				<ModernChoiceDialog
					open={modernChoiceDialogOpen}
					onClose={() => setModernChoiceDialogOpen(false)}
					onConfirm={(value) => {
						console.log("Modern choice selected:", value);
						setModernChoiceDialogOpen(false);
					}}
					title="Print Choice for Normal Patient List"
					options={[
						{ value: "without-space", label: "Print without in-line space" },
						{ value: "with-space", label: "Print with in-line space" },
					]}
					defaultValue="without-space"
				/>

				<ModernYesNoDialog
					open={modernYesNoDialogOpen}
					onClose={() => setModernYesNoDialogOpen(false)}
					onConfirm={() => {
						console.log("Modern yes/no confirmed");
						setModernYesNoDialogOpen(false);
					}}
					message={
						<>
							<strong>
								You are attempting to access a patient&apos; record which you
								might NOT be authorized. You are required to give full details
								of the supporting reasons for accessing this record.
							</strong>
							<br />
							<br />
							Your access will be logged and subject to vigilant auditing. Do
							you wish to continue?
						</>
					}
				/>

				<AccessReasonDialog
					open={accessReasonDialogOpen}
					onClose={() => setAccessReasonDialogOpen(false)}
					onSave={(reason, details) => {
						console.log("Access Reason:", reason, "Details:", details);
						setAccessReasonDialogOpen(false);
					}}
					title="CMS access purpose for patient currently not under hospital level case"
					instructionText="If yes, please identify one of the following access reasons and provide detail:"
					options={ACCESS_REASON_OPTIONS}
					warningText="Please provide sufficient details for access reason, otherwise your access will be subjected to audit check. Unauthorised access may lead to disciplinary action and possible legal consequence."
				/>

				<ModernAccessReasonDialog
					open={modernAccessReasonDialogOpen}
					onClose={() => setModernAccessReasonDialogOpen(false)}
					onSave={(reason, details) => {
						console.log("Modern Access Reason:", reason, "Details:", details);
						setModernAccessReasonDialogOpen(false);
					}}
					title="Print Choice for Normal Patient List"
					options={MODERN_ACCESS_REASON_OPTIONS}
					warningText="Please provide sufficient details for access reason, otherwise your access will be subjected to audit check. Unauthorised access may lead to disciplinary action and possible legal consequence."
				/>
			</Box>
		</ThemeProvider>
	);
}
