import fs from "fs";
import path from "path";
import yaml from "js-yaml";
import { ContextCard, ContextData } from "./ContextCard";

async function getContexts(): Promise<{ contexts: ContextData[]; error?: string }> {
  try {
    const contextsDir = path.join(process.cwd(), "contexts");
    const entries = fs.readdirSync(contextsDir, { withFileTypes: true });
    
    const contexts: ContextData[] = [];
    
    for (const entry of entries) {
      // Skip files, only process directories
      if (!entry.isDirectory()) continue;
      
      const metaPath = path.join(contextsDir, entry.name, "_meta.yaml");
      
      // Check if _meta.yaml exists
      if (!fs.existsSync(metaPath)) continue;
      
      try {
        const content = fs.readFileSync(metaPath, "utf8");
        const data = yaml.load(content) as ContextData;
        
        // Add the README content if it exists
        const readmePath = path.join(contextsDir, entry.name, "README.md");
        if (fs.existsSync(readmePath)) {
          data.content = fs.readFileSync(readmePath, "utf8");
        }
        
        // Count snippets in the snippets folder
        const snippetsPath = path.join(contextsDir, entry.name, "snippets");
        if (fs.existsSync(snippetsPath)) {
          try {
            const snippetFiles = fs.readdirSync(snippetsPath);
            data.snippetsCount = snippetFiles.filter(file => 
              file.endsWith('.md') || file.endsWith('.markdown')
            ).length;
          } catch (err) {
            console.error(`Error counting snippets for ${entry.name}:`, err);
            data.snippetsCount = 0;
          }
        } else {
          data.snippetsCount = 0;
        }
        
        contexts.push(data);
      } catch (err) {
        console.error(`Error parsing ${entry.name}/_meta.yaml:`, err);
      }
    }
    
    return { contexts };
  } catch (error) {
    console.error("Error loading contexts:", error);
    return { contexts: [], error: "Failed to load contexts" };
  }
}

function filterContexts(
  contexts: ContextData[],
  searchParams: { [key: string]: string | string[] | undefined }
): ContextData[] {
  return contexts.filter(context => {
    // Check tech stacks filter
    if (searchParams.techStacks) {
      const selectedTechStacks = (typeof searchParams.techStacks === 'string' 
        ? searchParams.techStacks.split(',') 
        : searchParams.techStacks) || [];
      
      if (selectedTechStacks.length > 0 && context.techStacks) {
        const hasMatchingTech = selectedTechStacks.some(tech => 
          context.techStacks?.includes(tech)
        );
        if (!hasMatchingTech) return false;
      }
    }
    
    // Check teams filter
    if (searchParams.teams) {
      const selectedTeams = (typeof searchParams.teams === 'string' 
        ? searchParams.teams.split(',') 
        : searchParams.teams) || [];
      
      if (selectedTeams.length > 0 && context.teams) {
        const hasMatchingTeam = selectedTeams.some(team => 
          context.teams?.includes(team)
        );
        if (!hasMatchingTeam) return false;
      }
    }
    

    
    // Check categories filter
    if (searchParams.categories) {
      const selectedCategories = (typeof searchParams.categories === 'string' 
        ? searchParams.categories.split(',') 
        : searchParams.categories) || [];
      
      if (selectedCategories.length > 0 && context.categories) {
        const hasMatchingCategory = selectedCategories.some(category => 
          context.categories?.includes(category)
        );
        if (!hasMatchingCategory) return false;
      }
    }
    
    return true;
  });
}

export default async function ContextsPage({
  searchParams,
}: {
  searchParams: Promise<{ [key: string]: string | string[] | undefined }>;
}) {
  const { contexts, error } = await getContexts();
  const resolvedSearchParams = await searchParams;
  
  if (error) {
    return (
      <div className="flex justify-center items-center h-[90vh]">
        <p className="text-red-500">{error}</p>
      </div>
    );
  }

  const filteredContexts = filterContexts(contexts, resolvedSearchParams);
  
  if (contexts.length === 0) {
    return (
      <div className="flex justify-center items-center h-[90vh]">
        <p className="text-2xl text-muted-foreground">No contexts found. Create context folders with _meta.yaml files in the /contexts directory.</p>
      </div>
    );
  }
  
  if (filteredContexts.length === 0) {
    return (
      <div className="p-8">
        <h1 className="text-2xl font-bold mb-6">Contexts</h1>
        <p className="text-muted-foreground">No contexts match the selected filters. Try adjusting your filters.</p>
      </div>
    );
  }
  
  return (
    <div className="p-8">
      <div className="mb-6">
        <h1 className="text-2xl font-bold mb-2">Contexts</h1>
        <p className="text-muted-foreground">
          {filteredContexts.length} of {contexts.length} contexts
        </p>
      </div>
      
      <div className="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-6">
        {filteredContexts.map((context) => (
          <ContextCard
            key={context.slug}
            context={context}
          />
        ))}
      </div>
    </div>
  );
}
