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
import { SkillMarkdownDialog } from "./SkillMarkdownDialog";

interface SkillCardProps {
	readonly name: string;
	readonly description: string;
	readonly source: string;
	readonly folderPath: string;
	readonly files: { name: string; relativePath: string }[];
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
			<CardFooter className="pt-3 flex flex-wrap gap-2">
				<SkillMarkdownDialog
					skillName={name}
					description={description}
					folderPath={folderPath}
					files={files}
				/>
				<Button
					asChild
					variant="outline"
					size="sm"
					className="w-full justify-center gap-2 sm:w-auto sm:min-w-[12rem] sm:flex-1"
				>
					<a
						href={`/api/skills/download?path=${encodeURIComponent(folderPath)}&name=${encodeURIComponent(name)}`}
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
