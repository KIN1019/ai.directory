import fs from "fs";
import path from "path";
import yaml from "js-yaml";
import { ContextData } from "../ContextCard";

export interface SnippetFile {
  name: string;
  content: string;
  path: string;
}

export interface ContextWithSnippets extends ContextData {
  snippets: SnippetFile[];
}

export async function getContextBySlug(slug: string): Promise<ContextWithSnippets | null> {
  try {
    const contextsDir = path.join(process.cwd(), "contexts");
    const contextPath = path.join(contextsDir, slug);
    
    // Check if context directory exists
    if (!fs.existsSync(contextPath)) {
      return null;
    }
    
    const metaPath = path.join(contextPath, "_meta.yaml");
    
    // Check if _meta.yaml exists
    if (!fs.existsSync(metaPath)) {
      return null;
    }
    
    // Read metadata
    const metaContent = fs.readFileSync(metaPath, "utf8");
    const context = yaml.load(metaContent) as ContextData;
    
    // Read README content
    const readmePath = path.join(contextPath, "README.md");
    if (fs.existsSync(readmePath)) {
      context.content = fs.readFileSync(readmePath, "utf8");
    }
    
    // Read snippets
    const snippetsPath = path.join(contextPath, "snippets");
    const snippets: SnippetFile[] = [];
    
    if (fs.existsSync(snippetsPath)) {
      const snippetFiles = fs.readdirSync(snippetsPath);
      
      for (const file of snippetFiles) {
        if (file.endsWith('.md') || file.endsWith('.markdown')) {
          const filePath = path.join(snippetsPath, file);
          const content = fs.readFileSync(filePath, "utf8");
          
          snippets.push({
            name: file.replace(/\.(md|markdown)$/, ''),
            content,
            path: file
          });
        }
      }
    }
    
    // Count snippets
    context.snippetsCount = snippets.length;
    
    return {
      ...context,
      snippets
    };
  } catch (error) {
    console.error("Error loading context:", error);
    return null;
  }
}

export function formatDate(dateString?: string): string {
  if (!dateString) return 'N/A';
  try {
    const date = new Date(dateString);
    const now = new Date();
    const diffTime = Math.abs(now.getTime() - date.getTime());
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    return `${diffDays} days ago (${date.toLocaleDateString()})`;
  } catch {
    return dateString;
  }
}

export function renderSourceUrl(source?: string): string | null {
  if (!source) return null;

  // Check if it's a GitHub repo format (/owner/repo)
  if (source.startsWith('/')) {
    return `https://github.com${source}`;
  }

  // Check if it's a full URL
  if (source.startsWith('http://') || source.startsWith('https://')) {
    return source;
  }

  return source;
} 