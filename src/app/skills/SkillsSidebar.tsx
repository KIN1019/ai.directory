import { getAllSkills } from "@/lib/skills";
import { SkillsSidebarNav } from "./SkillsSidebarNav";

function SkillsSidebar() {
	const skills = getAllSkills();

	const sourceMap = new Map<string, number>();
	for (const skill of skills) {
		sourceMap.set(skill.source, (sourceMap.get(skill.source) ?? 0) + 1);
	}

	const sources = Array.from(sourceMap.entries())
		.map(([name, count]) => ({ name, count }))
		.sort((a, b) => a.name.localeCompare(b.name));

	return <SkillsSidebarNav sources={sources} />;
}

export { SkillsSidebar };
