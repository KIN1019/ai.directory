"use client";

import {
	Card,
	CardContent,
	CardDescription,
	CardFooter,
	CardHeader,
	CardTitle,
} from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Download, FileText } from "lucide-react";

interface SkillCardProps {
	name: string;
	description: string;
	source: string;
	folderPath: string;
	files: { name: string; relativePath: string }[];
}

export function SkillCard({
	name,
	description,
	source,
	folderPath,
	files,
}: SkillCardProps) {
	const displayFiles = files.slice(0, 5);
	const remaining = files.length - displayFiles.length;

	return (
		<Card className="flex flex-col h-full">
			<CardHeader className="pb-3">
				<CardTitle className="text-base leading-snug">{name}</CardTitle>
				<CardDescription className="line-clamp-3 text-sm">
					{description}
				</CardDescription>
			</CardHeader>
			<CardContent className="flex-1">
				<p className="text-xs font-medium text-muted-foreground mb-3 truncate">
					{source}
				</p>
				<div className="flex flex-wrap gap-1.5">
					{displayFiles.map((f) => (
						<span
							key={f.relativePath}
							className="flex items-center gap-1 text-xs bg-muted px-2 py-0.5 rounded-full"
						>
							<FileText className="w-3 h-3 shrink-0" />
							<span className="truncate max-w-[140px]">{f.name}</span>
						</span>
					))}
					{remaining > 0 && (
						<span className="text-xs text-muted-foreground px-2 py-0.5">
							+{remaining} more
						</span>
					)}
				</div>
			</CardContent>
			<CardFooter className="pt-3">
				<Button asChild variant="outline" size="sm" className="w-full gap-2">
					<a
						href={`/api/skills/download?path=${encodeURIComponent(folderPath)}`}
						download
					>
						<Download className="w-4 h-4" />
						Download Skill Folder
					</a>
				</Button>
			</CardFooter>
		</Card>
	);
}
