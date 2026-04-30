import fs from "node:fs";
import path from "node:path";
import matter from "gray-matter";

export type SkillFile = {
	name: string;
	relativePath: string;
};

export type Skill = {
	name: string;
	description: string;
	folderPath: string;
	skillsDirPath: string;
	source: string;
	files: SkillFile[];
};

function toUnixPath(p: string): string {
	return p.replaceAll("\\", "/");
}

function walkDir(dir: string, base: string): SkillFile[] {
	const results: SkillFile[] = [];
	const entries = fs.readdirSync(dir, { withFileTypes: true });

	for (const entry of entries) {
		const fullPath = path.join(dir, entry.name);
		const relative = toUnixPath(path.relative(base, fullPath));
		if (entry.isDirectory()) {
			results.push(...walkDir(fullPath, base));
		} else {
			results.push({ name: entry.name, relativePath: relative });
		}
	}

	return results;
}

function walkFiles(
	dir: string,
	matcher: (filePath: string) => boolean,
): string[] {
	const results: string[] = [];
	const entries = fs.readdirSync(dir, { withFileTypes: true });

	for (const entry of entries) {
		const fullPath = path.join(dir, entry.name);
		if (entry.isDirectory()) {
			results.push(...walkFiles(fullPath, matcher));
		} else if (matcher(fullPath)) {
			results.push(fullPath);
		}
	}

	return results;
}

function findRepoName(skillMdPath: string, docsRoot: string) {
	return (
		toUnixPath(path.relative(docsRoot, skillMdPath)).split("/")[0] ?? "unknown"
	);
}

function findSkillsBucket(skillFolderPath: string, repoRootPath: string) {
	let current = path.dirname(skillFolderPath);

	while (current.startsWith(repoRootPath)) {
		if (path.basename(current).toLowerCase() === "skills") {
			return current;
		}

		const parent = path.dirname(current);
		if (parent === current) {
			break;
		}

		current = parent;
	}

	return path.dirname(skillFolderPath);
}

function buildSkill(
	skillMdPath: string,
	docsRoot: string,
	cwd: string,
): Skill | null {
	if (!fs.existsSync(skillMdPath)) return null;

	const skillFolderPath = path.dirname(skillMdPath);
	const repo = findRepoName(skillMdPath, docsRoot);
	const repoRootPath = path.join(docsRoot, repo);
	const skillsDir = findSkillsBucket(skillFolderPath, repoRootPath);
	const content = fs.readFileSync(skillMdPath, "utf8");
	const { data } = matter(content);
	const skillFolder = path.basename(skillFolderPath);

	return {
		name: data.name || skillFolder,
		description:
			typeof data.description === "string" ? data.description.trim() : "",
		folderPath: toUnixPath(path.relative(cwd, skillFolderPath)),
		skillsDirPath: toUnixPath(path.relative(cwd, skillsDir)),
		source: repo,
		files: walkDir(skillFolderPath, skillFolderPath),
	};
}

export function getAllSkills(): Skill[] {
	const cwd = process.cwd();
	const docsRoot = path.join(cwd, "reference");
	if (!fs.existsSync(docsRoot)) return [];

	const skillMarkdownFiles = walkFiles(
		docsRoot,
		(filePath) => path.basename(filePath).toLowerCase() === "skill.md",
	);

	return skillMarkdownFiles
		.map((skillMdPath) => buildSkill(skillMdPath, docsRoot, cwd))
		.filter((skill): skill is Skill => skill !== null)
		.sort(
			(left, right) =>
				left.source.localeCompare(right.source) ||
				left.name.localeCompare(right.name),
		);
}
