/**
 * List of Hong Kong public hospitals organized by cluster.
 *
 * Reference: Hospital Authority official list
 */

export interface Hospital {
	code: string;
	name: string;
	cluster: string;
}

export const HONG_KONG_HOSPITALS: Hospital[] = [
	// Hong Kong East Cluster (HKEC)
	{
		code: "PYNEH",
		name: "Pamela Youde Nethersole Eastern Hospital",
		cluster: "HKEC",
	},
	{ code: "RH", name: "Ruttonjee Hospital", cluster: "HKEC" },

	// Hong Kong West Cluster (HKWC)
	{ code: "QMH", name: "Queen Mary Hospital", cluster: "HKWC" },

	// Kowloon Central Cluster (KCC)
	{ code: "QEH", name: "Queen Elizabeth Hospital", cluster: "KCC" },
	{ code: "KH", name: "Kowloon Hospital", cluster: "KCC" },

	// Kowloon East Cluster (KEC)
	{ code: "UCH", name: "United Christian Hospital", cluster: "KEC" },
	{ code: "TKO", name: "Tseung Kwan O Hospital", cluster: "KEC" },

	// Kowloon West Cluster (KWC)
	{ code: "PMH", name: "Princess Margaret Hospital", cluster: "KWC" },
	{ code: "CMC", name: "Caritas Medical Centre", cluster: "KWC" },
	{ code: "YCH", name: "Yan Chai Hospital", cluster: "KWC" },

	// New Territories East Cluster (NTEC)
	{ code: "PWH", name: "Prince of Wales Hospital", cluster: "NTEC" },
	{ code: "NDH", name: "North District Hospital", cluster: "NTEC" },

	// New Territories West Cluster (NTWC)
	{ code: "TMH", name: "Tuen Mun Hospital", cluster: "NTWC" },
];

/**
 * Get hospital display name with code
 */
export function getHospitalDisplayName(hospital: Hospital): string {
	return `${hospital.code} - ${hospital.name}`;
}

/**
 * Group hospitals by cluster
 */
export function getHospitalsByCluster(): Map<string, Hospital[]> {
	const grouped = new Map<string, Hospital[]>();
	for (const hospital of HONG_KONG_HOSPITALS) {
		const existing = grouped.get(hospital.cluster) ?? [];
		grouped.set(hospital.cluster, [...existing, hospital]);
	}
	return grouped;
}
