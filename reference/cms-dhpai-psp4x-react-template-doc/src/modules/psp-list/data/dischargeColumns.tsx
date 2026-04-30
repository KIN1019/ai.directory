import {
	GridColDef,
	GridRenderCellParams,
	GridValidRowModel,
} from "@mui/x-data-grid-pro";
import { LockIcon, LockHeaderIcon } from "../components";
import type { PatientGridRow } from "../types";
import { ChiTypography } from "@cmschassis/react-ui";
import { formatDateTime, calculateAge } from "../utils/dateFormat";

/**
 * Column definitions for the discharge patient list grid.
 */
export const dischargeColumns: GridColDef<PatientGridRow>[] = [
	{
		field: "bedNo",
		headerName: "Bed",
		minWidth: 50,
		maxWidth: 80,
	},
	{
		field: "wardCode",
		headerName: "Ward",
		minWidth: 50,
		maxWidth: 80,
	},
	{
		field: "sexAge",
		headerName: "Sex/Age",
		minWidth: 60,
		maxWidth: 100,
		valueGetter: (_value, row) => {
			const sex = row.sex ?? "";
			const age = calculateAge(row.dob);
			return age ? `${sex}/${age}` : sex;
		},
	},
	{
		field: "chineseName",
		headerName: "Chinese Name",
		minWidth: 80,
		maxWidth: 150,
		renderCell: (params) => <ChiTypography>{params.value}</ChiTypography>,
	},
	{
		field: "name",
		headerName: "English Name",
		minWidth: 140,
		maxWidth: 300,
		cellClassName: "uppercase-cell",
	},
	{
		field: "locked",
		minWidth: 30,
		maxWidth: 50,
		resizable: false,
		renderHeader: () => <LockHeaderIcon />,
		renderCell: (params: GridRenderCellParams<GridValidRowModel, boolean>) => {
			// accessCode % 2 === 0 means locked
			const row = params.row as PatientGridRow;
			const accessCode = row.accessCode ? parseInt(row.accessCode, 10) : 1;
			const isLocked = !isNaN(accessCode) && accessCode % 2 === 0;
			return <LockIcon locked={isLocked} />;
		},
		sortable: false,
		disableColumnMenu: true,
	},
	{
		field: "caseNo",
		headerName: "Episode",
		minWidth: 130,
		maxWidth: 200,
		valueFormatter: (value: string | null) => {
			if (!value) return "";
			const trimmed = value.trim();
			if (trimmed.length > 0) {
				const lastChar = trimmed.slice(-1);
				const rest = trimmed.slice(0, -1);
				return `${rest}(${lastChar})`;
			}
			return trimmed;
		},
	},
	{
		field: "specCode",
		headerName: "Spec.",
		minWidth: 50,
		maxWidth: 100,
	},
	{
		field: "wardClass",
		headerName: "Class",
		minWidth: 50,
		maxWidth: 80,
	},
	{
		field: "admissionDtm",
		headerName: "Admission Date/Time",
		minWidth: 140,
		maxWidth: 200,
		valueFormatter: (value: string | null) => formatDateTime(value),
	},
	{
		field: "dischargeDtm",
		headerName: "Discharge Date/Time",
		minWidth: 140,
		maxWidth: 200,
		valueFormatter: (value: string | null) => formatDateTime(value),
	},
	{
		field: "sourceCode",
		headerName: "Source",
		minWidth: 70,
		maxWidth: 120,
		cellClassName: "highlight-cell",
	},
	{
		field: "hkid",
		headerName: "HKID",
		minWidth: 100,
		maxWidth: 150,
		valueFormatter: (value: string | null) => {
			if (!value) return "";
			return `(${value.trim()})`;
		},
	},
	{
		field: "mrn",
		headerName: "MRN",
		minWidth: 90,
		maxWidth: 130,
	},
	{
		field: "confidential",
		headerName: "Confidential",
		minWidth: 85,
		flex: 1,
		resizable: false,
		valueGetter: (_value, row) => {
			const accessCode = row.accessCode ? parseInt(row.accessCode, 10) : 1;
			return !isNaN(accessCode) && accessCode % 2 === 0 ? "YES" : "";
		},
		cellClassName: (params) => (params.value === "YES" ? "highlight-cell" : ""),
	},
];
