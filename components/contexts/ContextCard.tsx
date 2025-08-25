"use client";

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Code2, Users, FolderOpen, Calendar, FileText, ExternalLink, Github, LucideIcon } from "lucide-react";
import { useRouter } from "next/navigation";

export interface ContextData {
  name: string;
  description: string;
  slug: string;
  source?: string;
  lastUpdated?: string;
  snippetsCount?: number;
  techStacks?: string[];
  teams?: string[];
  categories?: string[];
  content?: string;
}

interface ContextCardProps {
  context: ContextData;
}

interface BadgeSectionProps {
  icon: LucideIcon;
  items: string[];
}

interface MetaItemProps {
  icon?: LucideIcon;
  children: React.ReactNode;
}

function BadgeSection({ icon: Icon, items }: BadgeSectionProps) {
  if (!items || items.length === 0) return null;

  return (
    <div className="flex items-start gap-2">
      <Icon className="w-4 h-4 text-muted-foreground mt-0.5" />
      <div className="flex flex-wrap gap-1">
        {items.map((item) => (
          <Badge key={item} variant="secondary" className="text-xs">
            {item}
          </Badge>
        ))}
      </div>
    </div>
  );
}

function MetaItem({ icon: Icon, children }: MetaItemProps) {
  return (
    <div className="flex items-center gap-1">
      {Icon && <Icon className="w-3 h-3" />}
      {children}
    </div>
  );
}

export function ContextCard({ context }: ContextCardProps) {
  const router = useRouter();

  const handleClick = () => {
    router.push(`/contexts/${context.slug}`);
  };

  const formatDate = (dateString?: string) => {
    if (!dateString) return 'N/A';
    try {
      return new Date(dateString).toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
      });
    } catch {
      return dateString;
    }
  };

  const renderSource = (source?: string) => {
    if (!source) return null;

    const handleSourceClick = (e: React.MouseEvent) => {
      e.stopPropagation(); // Prevent card click
    };

    // Check if it's a GitHub repo format (/owner/repo)
    if (source.startsWith('/')) {
      const githubUrl = `https://github.com${source}`;
      return (
        <a
          href={githubUrl}
          target="_blank"
          rel="noopener noreferrer"
          onClick={handleSourceClick}
          className="flex items-center gap-1 text-teal-600 hover:text-teal-800 dark:text-teal-400 dark:hover:text-teal-300"
        >
          <Github className="w-3 h-3" />
          <span className="text-xs">{source}</span>
          <ExternalLink className="w-2.5 h-2.5" />
        </a>
      );
    }

    // Check if it's a full URL
    if (source.startsWith('http://') || source.startsWith('https://')) {
      return (
        <a
          href={source}
          target="_blank"
          rel="noopener noreferrer"
          onClick={handleSourceClick}
          className="flex items-center gap-1 text-teal-600 hover:text-teal-800 dark:text-teal-400 dark:hover:text-teal-300"
        >
          <ExternalLink className="w-3 h-3" />
          <span className="text-xs truncate max-w-[150px]" title={source}>
            {source.replace(/^https?:\/\//, '')}
          </span>
        </a>
      );
    }

    // Fallback for other formats
    return (
      <div className="flex items-center gap-1">
        <ExternalLink className="w-3 h-3" />
        <span className="text-xs">{source}</span>
      </div>
    );
  };

  return (
    <Card 
      className="hover:shadow-lg transition-shadow cursor-pointer"
      onClick={handleClick}
    >
      <CardHeader>
        <CardTitle className="text-lg">{context.name}</CardTitle>
        <CardDescription className="h-10 overflow-hidden">{context.description}</CardDescription>
      </CardHeader>
      <CardContent className="space-y-3">
        {/* Source and Meta Information */}
        <div className="space-y-1 text-sm text-muted-foreground">
          {context.source && (
            <MetaItem>
              {renderSource(context.source)}
            </MetaItem>
          )}
          {context.snippetsCount !== undefined && (
            <MetaItem icon={FileText}>
              <span className="text-xs">{context.snippetsCount} snippet{context.snippetsCount !== 1 ? 's' : ''}</span>
            </MetaItem>
          )}
          {context.lastUpdated && (
            <MetaItem icon={Calendar}>
              <span className="text-xs">{formatDate(context.lastUpdated)}</span>
            </MetaItem>
          )}
        </div>

        {/* Badge Sections */}
        <BadgeSection icon={Code2} items={context.techStacks || []} />
        <BadgeSection icon={Users} items={context.teams || []} />
        <BadgeSection icon={FolderOpen} items={context.categories || []} />
      </CardContent>
    </Card>
  );
}
