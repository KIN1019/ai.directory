import fs from "fs";
import path from "path";
import yaml from "js-yaml";
import matter from "gray-matter";

type Tag = {
    slug: string;
 	name: string;
 	count?: number;
 	section?: string;
};

type SidebarGroup = {
    title: string;
    key: string;
    items: {
        slug: string;
        name: string;
        count: number;
    }[];
};

async function getRulesTags(): Promise<{ tags: Tag[] } | { error: string }> {
	try {
		const rulesDirectory = path.join(process.cwd(), "resources", "rules");
		const fileNames = fs
			.readdirSync(rulesDirectory)
			.filter((file) => file.endsWith(".md"));

		const tagsYamlPath = path.join(rulesDirectory, "tags.yaml");
		const tagsYamlContent = fs.readFileSync(tagsYamlPath, "utf8");
		const tagsList = yaml.load(tagsYamlContent) as Tag[];

		const tagsMap = new Map<string, Tag>();
		tagsList.forEach((tag) => tagsMap.set(tag.slug, tag));

		const tagCounts = new Map<string, number>();

		const uniqueTags = new Set<string>();

		fileNames.forEach((fileName) => {
			const filePath = path.join(rulesDirectory, fileName);
			const fileContent = fs.readFileSync(filePath, "utf8");
			const { data } = matter(fileContent);

			if (data.tags && Array.isArray(data.tags)) {
				data.tags.forEach((tag: string) => {
					uniqueTags.add(tag);
					// Increment tag count
					tagCounts.set(tag, (tagCounts.get(tag) || 0) + 1);
				});
			}
		});

		// Check if all tags exist in tags.yaml
		const validTags: Tag[] = [];
		const missingTags: string[] = [];

		uniqueTags.forEach((tag) => {
			if (tagsMap.has(tag)) {
				const tagData = tagsMap.get(tag)!;
				// Add count to tag data
				validTags.push({
					...tagData,
					count: tagCounts.get(tag) || 0,
				});
			} else {
				missingTags.push(tag);
			}
		});

		if (missingTags.length > 0) {
			throw new Error(
				`Tags found in markdown but not defined in tags.yaml: ${missingTags.join(", ")}`,
			);
		}

		return { tags: validTags };
	} catch (err) {
		console.error("Error loading tags:", err);
		return { error: err instanceof Error ? err.message : "Unknown error" };
	}
}

// tags.yaml 範例
// - slug: "writing"
//   name: "Writing Style"
//   section: "prompts"

async function getRulesSidebarData(): Promise<{ groups: SidebarGroup[] } | { error: string }> {
    const res = await getRulesTags();
    if ("error" in res) return { error: res.error };

    const tags = res.tags;

    const sections = [
        { key: "instructions", title: "Instructions" },
        { key: "chatmode", title: "Chatmode" },
        { key: "prompts", title: "Prompts" }
    ];

    const groups: SidebarGroup[] = sections.map((sec) => ({
        title: sec.title,
        key: sec.key,
        items: tags
            .filter((t) => (t.section ?? "prompts") === sec.key)
            .sort((a, b) => (b.count || 0) - (a.count || 0))
            .map((t) => ({
                slug: t.slug,
                name: t.name,
                count: t.count || 0,
            })),
    }));

    return { groups };
}


async function RulesSidebar() {
    const result = await getRulesSidebarData();
    if ("error" in result) return <p className="x:p-4 x:text-red-500">{result.error}</p>;
    const { groups } = result;

    return (
        <aside className="nextra-sidebar x:w-64 x:sticky x:top-(--nextra-navbar-height) x:h-[calc(100dvh-var(--nextra-navbar-height))] x:overflow-y-auto">
            <div className="x:p-4">
                {groups.map((group) => (
                    <div key={group.key} className="x:mb-6">
                        {/* 大標題 (Subtitle) */}
                        <h4 className="x:px-2 x:mb-2 x:text-xs x:font-semibold x:uppercase x:tracking-wider x:text-gray-500 x:dark:text-gray-400">
                            {group.title}
                        </h4>

                        {/* 該分組下的 Tags 列表 */}
                        <ul className="x:grid x:gap-1">
                            {group.items.map((item) => (
                                <li key={item.slug}>
                                    <a
                                        href={`/prompts/tags/${item.slug}`}
                                        className="x:flex x:items-center x:justify-between x:rounded x:px-2 x:py-1.5 x:text-sm x:hover:bg-gray-100 x:dark:hover:bg-neutral-800"
                                    >
                                        <span className="x:truncate">{item.name}</span>
                                        <span className="x:text-xs x:text-gray-400">{item.count}</span>
                                    </a>
                                </li>
                            ))}
                        </ul>
                    </div>
                ))}
            </div>
        </aside>
    );
}

export { RulesSidebar };
