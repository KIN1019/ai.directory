import fs from "fs";
import path from "path";
import yaml from "js-yaml";
import { FilterGroup } from "./ContextsMultiSelectSidebar";
import { ContextsLayoutClient } from "./ContextsLayoutClient";

type TagDefinition = {
  slug: string;
  name: string;
}

type ContextTags = {
  techStacks: TagDefinition[];
  teams: TagDefinition[];
  categories: TagDefinition[];
}

async function getContextTags(): Promise<{ filterGroups: FilterGroup[]; error?: string }> {
  try {
    const tagsPath = path.join(process.cwd(), "contexts", "tags.yaml");
    const tagsContent = fs.readFileSync(tagsPath, "utf8");
    const tags = yaml.load(tagsContent) as ContextTags;
    
    const filterGroups: FilterGroup[] = [
      {
        name: "Tech Stack",
        key: "techStacks",
        items: tags.techStacks || []
      },
      {
        name: "Team",
        key: "teams",
        items: tags.teams || []
      },

      {
        name: "Category",
        key: "categories",
        items: tags.categories || []
      }
    ];
    
    return { filterGroups };
  } catch (error) {
    console.error("Error loading context tags:", error);
    return { 
      filterGroups: [],
      error: "Failed to load filter categories"
    };
  }
}

export default async function ContextsLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  const { filterGroups, error } = await getContextTags();

  return (
    <ContextsLayoutClient filterGroups={filterGroups} error={error}>
      {children}
    </ContextsLayoutClient>
  );
} 