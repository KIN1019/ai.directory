import type { NormalPatList } from "../types";

const API_BASE_URL = "/api";
// Access environment variable (rsbuild uses REACT_APP_ prefix)
const API_KEY = process.env.REACT_APP_PSP_API_KEY;

export interface FetchDischargedPatientsParams {
	currWard: string;
	hospCode: string;
	pspDayDischarged: string;
}

export interface FetchDischargedPatientsResult {
	data: NormalPatList[];
	error: string | null;
}

/**
 * Fetches discharged patients from the PSP API.
 */
export async function fetchDischargedPatients(
	params: FetchDischargedPatientsParams,
): Promise<FetchDischargedPatientsResult> {
	const { currWard, hospCode, pspDayDischarged } = params;

	const queryParams = new URLSearchParams({
		currWard,
		hospCode,
		pspDayDischarged,
	});

	const url = `${API_BASE_URL}/v1/patientList/getPspNormalPatListWithDischarged?${queryParams.toString()}`;

	const headers: HeadersInit = {
		"Content-Type": "application/json",
		"Accept-Charset": "UTF-8",
	};

	if (API_KEY) {
		headers["x-cms-psp-api-svc-api-key"] = API_KEY;
	}

	try {
		const response = await fetch(url, {
			method: "GET",
			headers,
		});

		if (!response.ok) {
			return {
				data: [],
				error: `API error: ${response.status} ${response.statusText}`,
			};
		}

		const data = (await response.json()) as NormalPatList[];
		return { data, error: null };
	} catch (error) {
		const message =
			error instanceof Error ? error.message : "Unknown error occurred";
		return { data: [], error: message };
	}
}
