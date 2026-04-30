/**
 * Date formatting utilities for patient data display.
 */

const MONTH_NAMES = [
	"Jan",
	"Feb",
	"Mar",
	"Apr",
	"May",
	"Jun",
	"Jul",
	"Aug",
	"Sep",
	"Oct",
	"Nov",
	"Dec",
] as const;

/**
 * Formats a date string from "yyyy-MM-dd HH:mm:ss.SSS" to "dd-MMM-yyyy HH:mm"
 * @param dateStr - The date string to format
 * @returns Formatted date string or empty string if invalid
 */
export function formatDateTime(dateStr: string | null): string {
	if (!dateStr) return "";
	try {
		const date = new Date(dateStr);
		if (isNaN(date.getTime())) return dateStr;

		const day = date.getDate().toString().padStart(2, "0");
		const month = MONTH_NAMES[date.getMonth()];
		const year = date.getFullYear();
		const hours = date.getHours().toString().padStart(2, "0");
		const minutes = date.getMinutes().toString().padStart(2, "0");

		return `${day}-${month}-${year} ${hours}:${minutes}`;
	} catch {
		return dateStr;
	}
}

/**
 * Calculates age from date of birth string
 * @param dobStr - Date of birth string
 * @returns Age string (e.g., "45y") or empty string if invalid
 */
export function calculateAge(dobStr: string | null): string {
	if (!dobStr) return "";
	try {
		const dob = new Date(dobStr);
		if (isNaN(dob.getTime())) return "";

		const today = new Date();
		let age = today.getFullYear() - dob.getFullYear();
		const monthDiff = today.getMonth() - dob.getMonth();

		if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < dob.getDate())) {
			age--;
		}

		return `${age}y`;
	} catch {
		return "";
	}
}
