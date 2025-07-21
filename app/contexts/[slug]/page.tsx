import { notFound } from "next/navigation";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { CheckCircle, Code2, Users, FolderOpen } from "lucide-react";
import { getContextBySlug, formatDate, renderSourceUrl } from "./utils";
import { BackButton } from "./components/BackButton";

export default async function ContextDetailPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const context = await getContextBySlug(slug);
  
  if (!context) {
    notFound();
  }

  const renderSource = (source?: string) => {
    const url = renderSourceUrl(source);
    if (!url) return null;

    return (
      <a
        href={url}
        target="_blank"
        rel="noopener noreferrer"
        className="text-teal-600 hover:text-teal-800 dark:text-teal-400 dark:hover:text-teal-300"
      >
        {url}
      </a>
    );
  };

  return (
    <div className="container mx-auto px-4 py-8 max-w-6xl">
      {/* Back Button */}
      <BackButton />
      
      {/* Header */}
      <div className="border rounded-lg p-6 mb-8">
        <div className="flex items-center justify-between mb-4">
          <h1 className="text-3xl font-bold">{context.name}</h1>
          <div className="flex items-center gap-4">
            <Button variant="outline" size="sm">Latest</Button>
            <Button variant="outline" size="sm">🔄 Refresh</Button>
            <Button variant="outline" size="sm">⚙️</Button>
            <Button variant="outline" size="sm">ℹ️</Button>
          </div>
        </div>
        
        {context.source && (
          <div className="mb-3">
            {renderSource(context.source)}
          </div>
        )}
        
        <p className="text-muted-foreground mb-4">{context.description}</p>
        
        <div className="flex items-center gap-6 text-sm">
          <div className="flex items-center gap-2">
            <CheckCircle className="w-4 h-4 text-teal-600" />
            <span className="font-medium">Completed</span>
          </div>
          
          {context.snippetsCount !== undefined && (
            <div>
              <span className="font-medium">Snippets:</span> {context.snippetsCount}
            </div>
          )}
          
          {context.lastUpdated && (
            <div>
              <span className="font-medium">Update:</span> {formatDate(context.lastUpdated)}
            </div>
          )}
        </div>
        
        {/* Tags/Badges */}
        <div className="mt-4 space-y-3">
          {context.techStacks && context.techStacks.length > 0 && (
            <div className="flex items-center gap-2">
              <Code2 className="w-4 h-4 text-muted-foreground" />
              <span className="text-sm font-medium">Tech Stack:</span>
              <div className="flex flex-wrap gap-1">
                {context.techStacks.map((tech) => (
                  <Badge key={tech} variant="secondary" className="text-xs bg-teal-800 text-white">
                    {tech}
                  </Badge>
                ))}
              </div>
            </div>
          )}
          
          {context.teams && context.teams.length > 0 && (
            <div className="flex items-center gap-2">
              <Users className="w-4 h-4 text-muted-foreground" />
              <span className="text-sm font-medium">Teams:</span>
              <div className="flex flex-wrap gap-1">
                {context.teams.map((team) => (
                  <Badge key={team} variant="secondary" className="text-xs bg-teal-800 text-white">
                    {team}
                  </Badge>
                ))}
              </div>
            </div>
          )}
          

          
          {context.categories && context.categories.length > 0 && (
            <div className="flex items-center gap-2">
              <FolderOpen className="w-4 h-4 text-muted-foreground" />
              <span className="text-sm font-medium">Categories:</span>
              <div className="flex flex-wrap gap-1">
                {context.categories.map((category) => (
                  <Badge key={category} variant="secondary" className="text-xs bg-teal-800 text-white">
                    {category}
                  </Badge>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Search Section */}
      <div className="mb-8">
        <h2 className="text-sm font-medium text-muted-foreground mb-4">SEARCH BY TOPIC</h2>
        <div className="border rounded-lg p-6">
          <div className="mb-4">
            <label className="text-sm font-medium">Show docs for...</label>
          </div>
          <div className="flex gap-4">
            <Input 
              placeholder="e.g. data fetching, routing, middleware"
              className="flex-1"
            />
            <Button className="bg-teal-800 hover:bg-teal-700 text-white">Show Results</Button>
          </div>
        </div>
      </div>

      {/* Content/Snippets Section */}
      <div>
        <h2 className="text-sm font-medium text-muted-foreground mb-4">CONTENT</h2>
        <div className="border rounded-lg">
          <div className="border-b p-4 flex items-center justify-between">
            <div className="flex items-center gap-4">
              <span className="text-sm">Content:</span>
              <select className="border rounded px-3 py-1 text-sm">
                <option>All Content</option>
              </select>
            </div>
            <div className="flex gap-2">
              <Button variant="outline" size="sm">📄 Raw</Button>
              <Button variant="outline" size="sm">📋 Copy</Button>
              <Button variant="outline" size="sm">🔗 Link</Button>
            </div>
          </div>
          
          <div className="p-6">
            {/* README Content */}
            {context.content && (
              <div className="mb-8">
                <pre className="bg-muted p-4 rounded-lg text-sm overflow-auto whitespace-pre-wrap">
                  {context.content}
                </pre>
              </div>
            )}
            
            {/* Snippets */}
            {context.snippets.map((snippet, index) => (
              <div key={snippet.path} className={index > 0 ? "mt-8" : ""}>
                <h3 className="text-lg font-semibold mb-3 capitalize">
                  {snippet.name.replace(/-/g, ' ')}
                </h3>
                <pre className="bg-muted p-4 rounded-lg text-sm overflow-auto whitespace-pre-wrap">
                  {snippet.content}
                </pre>
              </div>
            ))}
            
            {context.snippets.length === 0 && !context.content && (
              <div className="text-center text-muted-foreground py-8">
                No content or snippets available for this context.
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
} 