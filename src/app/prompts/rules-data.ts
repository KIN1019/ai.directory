import fs from "node:fs";
import path from "node:path";
import matter from "gray-matter";
import yaml from "js-yaml";

type RuleSection = "instructions" | "chatmodes" | "prompts" | "others";

type RuleDocument = {
	title: string;
	content: string;
	tags: string[];
	fileName: string;
	slug: string;
	description: string;
	section: RuleSection;
};

type RuleSourceFile = {
	absolutePath: string;
	fileName: string;
	relativePath: string;
	source: "resources" | "fetch_prompt_folder";
};

type RulesSidebarTag = {
	slug: string;
	name: string;
	count: number;
};

type RulesSidebarSection = {
	key: RuleSection;
	title: string;
	count: number;
	items: RulesSidebarTag[];
};

const RULES_DIRECTORY = path.join(process.cwd(), "resources", "rules");
const FETCHED_DOCS_DIRECTORY = path.join(process.cwd(), "fetch_prompt_folder");

const FETCHED_RULE_FILE_PATTERNS = [
	/\.chatmode\.md$/i,
	/\.instructions\.md$/i,
	/\.prompt\.md$/i,
	/README\.chatmodes\.md$/i,
	/README\.instructions\.md$/i,
	/README\.prompts\.md$/i,
];

const SECTION_META: Array<{ key: RuleSection; title: string }> = [
	{ key: "instructions", title: "Instructions" },
	{ key: "chatmodes", title: "Chatmodes" },
	{ key: "prompts", title: "Prompts" },
	{ key: "others", title: "Others" },
];

function listRuleFiles() {
	return fs
		.readdirSync(RULES_DIRECTORY)
		.filter(
			(file) => file.endsWith(".md") && file.toLowerCase() !== "readme.md",
		);
}

function walkFiles(dir: string): string[] {
	const results: string[] = [];
	const entries = fs.readdirSync(dir, { withFileTypes: true });

	for (const entry of entries) {
		const fullPath = path.join(dir, entry.name);
		if (entry.isDirectory()) {
			results.push(...walkFiles(fullPath));
		} else {
			results.push(fullPath);
		}
	}

	return results;
}

function toUnixPath(value: string) {
	return value.replaceAll("\\", "/");
}

function safeDecodeURIComponent(value: string) {
	try {
		return decodeURIComponent(value);
	} catch {
		return value;
	}
}

function stripRuleSuffixes(fileName: string) {
	return fileName
		.replace(/\.(chatmode|chatmodes|instructions|prompt|prompts)\.md$/i, "")
		.replace(/\.md$/i, "");
}

function slugifySegment(value: string) {
	return (
		safeDecodeURIComponent(stripRuleSuffixes(value))
			.toLowerCase()
			.replaceAll(/[^a-z0-9]+/g, "-")
			.replaceAll(/^-+|-+$/g, "") || "rule"
	);
}

function buildFetchedRuleSlug(filePath: string) {
	const relativePath = toUnixPath(
		path.relative(FETCHED_DOCS_DIRECTORY, filePath),
	);
	return relativePath.split("/").map(slugifySegment).join("--");
}

function isFetchedRuleCandidate(filePath: string) {
	const normalized = toUnixPath(filePath);
	return FETCHED_RULE_FILE_PATTERNS.some((pattern) => pattern.test(normalized));
}

function listFetchedRuleFiles(): RuleSourceFile[] {
	if (!fs.existsSync(FETCHED_DOCS_DIRECTORY)) {
		return [];
	}

	return walkFiles(FETCHED_DOCS_DIRECTORY)
		.filter(isFetchedRuleCandidate)
		.map((absolutePath) => ({
			absolutePath,
			fileName: path.basename(absolutePath),
			relativePath: toUnixPath(path.relative(process.cwd(), absolutePath)),
			source: "fetch_prompt_folder" as const,
		}));
}

function listAllRuleSourceFiles(): RuleSourceFile[] {
	const localRuleFiles = listRuleFiles().map((fileName) => {
		const absolutePath = path.join(RULES_DIRECTORY, fileName);
		return {
			absolutePath,
			fileName,
			relativePath: toUnixPath(path.relative(process.cwd(), absolutePath)),
			source: "resources" as const,
		};
	});

	return [...localRuleFiles, ...listFetchedRuleFiles()];
}

function formatFallbackName(value: string) {
	return safeDecodeURIComponent(value)
		.replace(/\.[^.]+$/, "")
		.split(/[-_.]+/)
		.filter(Boolean)
		.map((part) => part.charAt(0).toUpperCase() + part.slice(1))
		.join(" ");
}

function stripLeadingFrontmatterBlocks(rawContent: string) {
	let content = rawContent.trimStart();
	const frontmatterPattern = /^---\s*\r?\n[\s\S]*?\r?\n---\s*(?:\r?\n|$)/;

	while (frontmatterPattern.test(content)) {
		const match = frontmatterPattern.exec(content);
		if (!match) {
			break;
		}
		content = content.slice(match[0].length).trimStart();
	}

	return content;
}

function extractFirstHeading(content: string) {
	const headingMatch = /^#\s+(.+)$/m.exec(content);
	return headingMatch?.[1]?.trim();
}

function extractDescriptionFromContent(content: string) {
	const lines = content.split(/\r?\n/);
	let insideCodeBlock = false;

	for (const line of lines) {
		const trimmed = line.trim();
		if (trimmed.startsWith("```")) {
			insideCodeBlock = !insideCodeBlock;
			continue;
		}
		if (insideCodeBlock || trimmed.length === 0 || trimmed.startsWith("#")) {
			continue;
		}
		return trimmed;
	}

	return "";
}

function loadTagNames() {
	const tagsYamlPath = path.join(RULES_DIRECTORY, "tags.yaml");
	const tagNames = new Map<string, string>();

	try {
		const tagsYamlContent = fs.readFileSync(tagsYamlPath, "utf8");
		const tagsList = yaml.load(tagsYamlContent);

		if (Array.isArray(tagsList)) {
			tagsList.forEach((tag) => {
				if (
					tag &&
					typeof tag === "object" &&
					"slug" in tag &&
					"name" in tag &&
					typeof tag.slug === "string" &&
					typeof tag.name === "string"
				) {
					tagNames.set(tag.slug, tag.name);
				}
			});
		}
	} catch (error) {
		console.error("Error loading tags.yaml:", error);
	}

	return tagNames;
}

function inferTags(
	frontmatterTags: unknown,
	text: string,
	validTagSlugs: Set<string>,
) {
	const inferredTags: string[] = [];
	const normalizedText = text.toLowerCase();

	// Always include explicit frontmatter tags regardless of tags.yaml
	const explicitTags = Array.isArray(frontmatterTags)
		? frontmatterTags.filter(
				(tag): tag is string =>
					typeof tag === "string" && tag.trim().length > 0,
			)
		: [];

	// If frontmatter tags are provided, use them as-is without keyword inference
	if (explicitTags.length > 0) {
		return explicitTags;
	}

	const keywordMap: Array<[string, RegExp]> = [
		["dhpai", /dhpai|cms-dhpai/],
		["react", /react|jsx|tsx|component/],
		["typescript", /typescript|\.ts\b|\.tsx\b/],
		["java", /\bjava\b|maven|gradle/],
		["springboot", /spring\s*boot|@springbootapplication/],
		["jest", /\bjest\b|describe\(|it\(/],
		["junit", /\bjunit\b|@test\b/],
		["selenium", /selenium|webdriver/],
		["openshift", /openshift|\boc\s/],
		["mui", /material ui|@mui|\bmui\b/],
		["sonarqube", /sonarqube|\bsonar\b/],
		["github-actions", /github actions|workflow/],
		["postgresql", /postgresql|postgres/],
		["logging", /logging|log4j|clap/],
		["monitoring", /monitoring|apm|elastic apm/],
		["code-review", /code review|pr review/],
		["git", /\bgit\b/],
		["github", /github/],
		["vscode", /vs code|vscode/],
		["copilot", /github copilot|copilot/],
		["openapi", /openapi/],
		["swagger", /swagger/],
		["springdoc", /springdoc/],
		["testing", /\btest\b|testing/],
		["unit-testing", /unit test|unit testing/],
		["skills", /\bskill\b|skills/],
		["prompt-engineering", /prompt engineering|prompts?/],
		["schema-validation", /schema validation/],
		["security", /security/],
		["bugfix", /bug fix/],
		["bug-fixing", /bug fixing/],
		["ci", /\bci\b|continuous integration/],
	];

	for (const [slug, pattern] of keywordMap) {
		if (validTagSlugs.has(slug) && pattern.test(normalizedText)) {
			inferredTags.push(slug);
		}
	}

	const merged = [...new Set(inferredTags)];
	if (merged.length > 0) {
		return merged;
	}

	return ["dhpai"];
}

function buildRuleDocument(
	ruleFile: RuleSourceFile,
	validTagSlugs: Set<string>,
): RuleDocument {
	const fileContent = fs.readFileSync(ruleFile.absolutePath, "utf8");
	const { data } = matter(fileContent);
	const strippedContent = stripLeadingFrontmatterBlocks(fileContent);
	const sourceText = [
		ruleFile.relativePath,
		typeof data.title === "string" ? data.title : "",
		typeof data.description === "string" ? data.description : "",
		strippedContent,
	].join("\n");
	const baseName = stripRuleSuffixes(ruleFile.fileName);
	const title =
		typeof data.title === "string" && data.title.trim().length > 0
			? data.title.trim()
			: (extractFirstHeading(strippedContent) ?? formatFallbackName(baseName));
	const description =
		typeof data.description === "string" && data.description.trim().length > 0
			? data.description.trim()
			: extractDescriptionFromContent(strippedContent);

	return {
		title,
		description,
		content: strippedContent,
		tags: inferTags(data.tags, sourceText, validTagSlugs),
		fileName: ruleFile.fileName,
		slug:
			ruleFile.source === "resources"
				? ruleFile.fileName.replace(/\.md$/i, "")
				: buildFetchedRuleSlug(ruleFile.absolutePath),
		section: inferRuleSection(ruleFile.fileName),
	};
}

function inferRuleSection(fileName: string): RuleSection {
	const normalizedFileName = fileName.toLowerCase();

	if (normalizedFileName.includes("instructions")) {
		return "instructions";
	}

	if (normalizedFileName.includes("chatmode")) {
		return "chatmodes";
	}

	if (normalizedFileName.includes("prompt")) {
		return "prompts";
	}

	return "others";
}

function getRuleSectionTitle(section: RuleSection) {
	return SECTION_META.find((item) => item.key === section)?.title ?? section;
}

function isRuleSection(value: string): value is RuleSection {
	return SECTION_META.some((section) => section.key === value);
}

async function getAllRules(): Promise<RuleDocument[]> {
	const tagNames = loadTagNames();
	const validTagSlugs = new Set(tagNames.keys());

	return listAllRuleSourceFiles()
		.map((ruleFile) => buildRuleDocument(ruleFile, validTagSlugs))
		.sort((left, right) => left.title.localeCompare(right.title));
}

async function getRulesSidebarSections(): Promise<RulesSidebarSection[]> {
	const rules = await getAllRules();
	const tagNames = loadTagNames();

	return SECTION_META.map(({ key, title }) => {
		const sectionRules = rules.filter((rule) => rule.section === key);
		const tagCounts = new Map<string, number>();

		sectionRules.forEach((rule) => {
			new Set(rule.tags).forEach((tag) => {
				tagCounts.set(tag, (tagCounts.get(tag) ?? 0) + 1);
			});
		});

		const items = Array.from(tagCounts.entries())
			.map(([slug, count]) => ({
				slug,
				name: tagNames.get(slug) ?? formatFallbackName(slug),
				count,
			}))
			.sort(
				(left, right) =>
					right.count - left.count || left.name.localeCompare(right.name),
			);

		return {
			key,
			title,
			count: sectionRules.length,
			items,
		};
	});
}

async function getRulesBySection(section: RuleSection) {
	const rules = await getAllRules();
	return rules.filter((rule) => rule.section === section);
}

async function getRulesBySectionAndTag(section: RuleSection, tag: string) {
	const rules = await getRulesBySection(section);
	return rules.filter((rule) => rule.tags.includes(tag));
}

async function getRulesByTag(tag: string) {
	const rules = await getAllRules();
	return rules.filter((rule) => rule.tags.includes(tag));
}

async function getTagName(slug: string) {
	return loadTagNames().get(slug) ?? formatFallbackName(slug);
}

export type { RuleDocument, RuleSection, RulesSidebarSection };
export {
	getAllRules,
	getRuleSectionTitle,
	getRulesBySection,
	getRulesBySectionAndTag,
	getRulesByTag,
	getRulesSidebarSections,
	getTagName,
	inferRuleSection,
	isRuleSection,
};
