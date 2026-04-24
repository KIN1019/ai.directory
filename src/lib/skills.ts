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

function buildSkill(
	skillFolderPath: string,
	skillsDir: string,
	repo: string,
	cwd: string,
): Skill | null {
	const skillMdPath = path.join(skillFolderPath, "SKILL.md");
	if (!fs.existsSync(skillMdPath)) return null;

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

function collectSkillsFromDir(
	skillsDir: string,
	repo: string,
	cwd: string,
): Skill[] {
	if (!fs.existsSync(skillsDir)) return [];

	return fs
		.readdirSync(skillsDir, { withFileTypes: true })
		.filter((e) => e.isDirectory())
		.map((e) => buildSkill(path.join(skillsDir, e.name), skillsDir, repo, cwd))
		.filter((s): s is Skill => s !== null);
}

export function getAllSkills(): Skill[] {
	const cwd = process.cwd();
	const docsRoot = path.join(cwd, "fetched-dhpai-docs");

	const repos = fs
		.readdirSync(docsRoot, { withFileTypes: true })
		.filter((e) => e.isDirectory())
		.map((e) => e.name);

	return repos.flatMap((repo) => [
		...collectSkillsFromDir(
			path.join(docsRoot, repo, ".github", "skills"),
			repo,
			cwd,
		),
		...collectSkillsFromDir(
			path.join(docsRoot, repo, "skills"),
			repo,
			cwd,
		),
	]);
}
