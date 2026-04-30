import type { PatientGridRow } from "../types";

const FIRST_NAMES = [
	"CHAN",
	"WONG",
	"LEE",
	"LAU",
	"CHEUNG",
	"NG",
	"TANG",
	"LI",
	"HO",
	"YIP",
	"LEUNG",
	"TSANG",
	"CHOW",
	"LO",
	"MAK",
	"KWOK",
	"FUNG",
	"YEUNG",
	"TSE",
	"CHENG",
];

const LAST_NAMES = [
	"TAI MAN",
	"SIU MING",
	"WAI KIT",
	"KA YAN",
	"MEI LING",
	"HOI YAN",
	"WAI HUNG",
	"YUK YING",
	"CHI HUNG",
	"WING SHAN",
	"SIU WAI",
	"KA MAN",
	"HOI MAN",
	"WING YEE",
];

const CHINESE_NAMES = [
	"陳大文",
	"黃小明",
	"李偉傑",
	"劉嘉欣",
	"張美玲",
	"吳海燕",
	"鄧偉鴻",
	"林玉英",
	"何志鴻",
	"葉詠珊",
	"梁小慧",
	"曾家敏",
	"周海文",
	"羅詠儀",
];

const WARD_CODES = ["5A", "5B", "6A", "6B", "7A", "7B", "AE01"];
const SPEC_CODES = ["MED", "SUR", "ORT", "GYN", "PED", "ENT", "OPH", "PSY"];
const WARD_CLASSES = ["1", "2", "3", "A", "B", "C"];
const SOURCE_CODES = ["AE", "OPD", "TRF", "ADM", "EMR"];
const SEXES = ["M", "F"];

function randomItem<T>(arr: T[]): T {
	return arr[Math.floor(Math.random() * arr.length)];
}

function randomInt(min: number, max: number): number {
	return Math.floor(Math.random() * (max - min + 1)) + min;
}

function formatDate(date: Date): string {
	const pad = (n: number) => n.toString().padStart(2, "0");
	return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())} ${pad(date.getHours())}:${pad(date.getMinutes())}:${pad(date.getSeconds())}.000`;
}

function generateHKID(): string {
	const letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	const letter = letters[Math.floor(Math.random() * letters.length)];
	const numbers = Array.from({ length: 6 }, () => randomInt(0, 9)).join("");
	const checkDigit = randomInt(0, 9);
	return `${letter}${numbers}(${checkDigit})`;
}

function generateCaseNo(): string {
	const prefix = "HN";
	const year = randomInt(20, 26).toString().padStart(2, "0");
	const seq = randomInt(100000, 999999).toString();
	const checkDigit = randomInt(0, 9).toString();
	return `${prefix}${year}${seq}${checkDigit}`;
}

function generateMRN(): string {
	return `HN${randomInt(10000000, 99999999)}`;
}

function generateDOB(): string {
	const year = randomInt(1940, 2010);
	const month = randomInt(1, 12);
	const day = randomInt(1, 28);
	return `${year}-${month.toString().padStart(2, "0")}-${day.toString().padStart(2, "0")}`;
}

function generatePatient(index: number): PatientGridRow {
	const now = new Date();
	const admissionDaysAgo = randomInt(1, 90);
	const admissionDate = new Date(
		now.getTime() - admissionDaysAgo * 24 * 60 * 60 * 1000,
	);
	const dischargeDaysAgo = randomInt(0, admissionDaysAgo - 1);
	const dischargeDate = new Date(
		now.getTime() - dischargeDaysAgo * 24 * 60 * 60 * 1000,
	);

	const firstName = randomItem(FIRST_NAMES);
	const lastName = randomItem(LAST_NAMES);
	const caseNo = generateCaseNo();
	const wardCode = randomItem(WARD_CODES);
	const bedNo = `${wardCode.charAt(0)}${randomInt(1, 30).toString().padStart(2, "0")}`;

	return {
		id: `${caseNo}-${index}`,
		bedNo,
		name: `${firstName}, ${lastName}`,
		chineseName: randomItem(CHINESE_NAMES),
		sex: randomItem(SEXES),
		wardClass: randomItem(WARD_CLASSES),
		hkid: generateHKID(),
		dob: generateDOB(),
		wardCode,
		admissionDtm: formatDate(admissionDate),
		specCode: randomItem(SPEC_CODES),
		sysDtm1: formatDate(now),
		caseNo,
		year: now.getFullYear().toString(),
		month: (now.getMonth() + 1).toString().padStart(2, "0"),
		day: now.getDate().toString().padStart(2, "0"),
		getdate: formatDate(now),
		sysDtm2: formatDate(now),
		mrn: generateMRN(),
		sourceCode: randomItem(SOURCE_CODES),
		dob2: generateDOB(),
		deathIndicator: null,
		deathDate: null,
		accessCode: randomInt(1, 10).toString(),
		caseType: "IP",
		dischargeDtm: formatDate(dischargeDate),
		sarsStatus: null,
		surStatus: null,
		scFlag: null,
		uniCode1: null,
		uniCode2: null,
		uniCode3: null,
		uniCode4: null,
		uniCode5: null,
		uniCode6: null,
	};
}

/** Dummy patient list (1000 items). */
export const dummyPatients: PatientGridRow[] = Array.from(
	{ length: 1000 },
	(_, index) => generatePatient(index),
);
