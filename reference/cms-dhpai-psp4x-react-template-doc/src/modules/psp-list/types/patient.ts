/**
 * Patient data structure from the PSP API.
 * Based on the Java NormalPatList DTO.
 */
export interface NormalPatList {
	bedNo: string | null;
	name: string | null;
	chineseName: string | null;
	sex: string | null;
	wardClass: string | null;
	hkid: string | null;
	dob: string | null;
	wardCode: string | null;
	admissionDtm: string | null;
	specCode: string | null;
	sysDtm1: string | null;
	caseNo: string | null;
	year: string | null;
	month: string | null;
	day: string | null;
	getdate: string | null;
	sysDtm2: string | null;
	mrn: string | null;
	sourceCode: string | null;
	dob2: string | null;
	deathIndicator: string | null;
	deathDate: string | null;
	accessCode: string | null;
	caseType: string | null;
	dischargeDtm: string | null;
	sarsStatus: string | null;
	surStatus: string | null;
	scFlag: string | null;
	uniCode1: number | null;
	uniCode2: number | null;
	uniCode3: number | null;
	uniCode4: number | null;
	uniCode5: number | null;
	uniCode6: number | null;
}

/**
 * Row type for the DataGrid with an id field.
 */
export interface PatientGridRow extends NormalPatList {
	id: string;
}
