import { getAllSkills } from "@/lib/skills";
import { getSkillSourceLabel } from "@/lib/skill-source-map";
import { SkillCard } from "./SkillCard";
import { Button } from "@/components/ui/button";
import { Download } from "lucide-react";

type SkillsPageProps = {
	searchParams: Promise<{ source?: string }>;
};

export default async function SkillsPage({ searchParams }: SkillsPageProps) {
	const { source: selectedSource } = await searchParams;
	const allSkills = getAllSkills();
	const skills = selectedSource
		? allSkills.filter((s) => s.source === selectedSource)
		: allSkills;

	// Group by source, tracking the skillsDirPath per source (may differ across skill dirs)
	const grouped = skills.reduce<
		Record<string, { skills: typeof skills; buckets: Set<string> }>
	>((acc, skill) => {
		if (!acc[skill.source])
			acc[skill.source] = { skills: [], buckets: new Set() };
		acc[skill.source].skills.push(skill);
		acc[skill.source].buckets.add(skill.skillsDirPath);
		return acc;
	}, {});

	return (
		<div className="p-8 pb-32">
			<h1 className="text-2xl font-bold mb-2">Skills</h1>
			<p className="text-muted-foreground mb-10">
				AI agent skills from DHPAI repositories. Download any individual skill
				or the entire bucket from a repository.
			</p>
			{Object.entries(grouped).map(
				([source, { skills: sourceSkills, buckets }]) => (
					<section key={source} className="mb-12">
						<div className="flex items-center justify-between mb-4 gap-4 flex-wrap">
							<h2 className="text-sm font-semibold uppercase tracking-wide text-muted-foreground">
								{getSkillSourceLabel(source)}
							</h2>
							<div className="flex gap-2 flex-wrap">
								{Array.from(buckets).map((bucketPath) => (
									<Button
										key={bucketPath}
										asChild
										variant="secondary"
										size="sm"
										className="gap-2"
									>
										<a
											href={`/api/skills/download?path=${encodeURIComponent(bucketPath)}&name=${encodeURIComponent(source)}`}
											download
										>
											<Download className="w-3.5 h-3.5" />
											Download All (
											{
												sourceSkills.filter(
													(s) => s.skillsDirPath === bucketPath,
												).length
											}{" "}
											skills)
										</a>
									</Button>
								))}
							</div>
						</div>
						<div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 2xl:grid-cols-4 gap-4 items-start">
							{sourceSkills.map((skill) => (
								<SkillCard key={skill.folderPath} {...skill} />
							))}
						</div>
					</section>
				),
			)}
			{skills.length === 0 && (
				<p className="text-muted-foreground">No skills found.</p>
			)}
		</div>
	);
}
