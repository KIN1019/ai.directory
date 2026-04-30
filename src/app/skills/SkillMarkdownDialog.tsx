"use client";

import { useEffect, useMemo, useState } from "react";
import { FileText, LoaderCircle } from "lucide-react";

import { Button } from "@/components/ui/button";
import {
	Dialog,
	DialogContent,
	DialogDescription,
	DialogHeader,
	DialogTitle,
	DialogTrigger,
} from "@/components/ui/dialog";

type SkillMarkdownDialogProps = {
	readonly skillName: string;
	readonly description: string;
	readonly folderPath: string;
	readonly files: { name: string; relativePath: string }[];
};

type MarkdownResponse = {
	content: string;
	fileName: string;
	relativePath: string;
};

type MarkdownContentMap = Record<string, string>;

async function fetchMarkdownFile(
	folderPath: string,
	relativePath: string,
	signal: AbortSignal,
) {
	const params = new URLSearchParams({
		folderPath,
		relativePath,
	});
	const response = await fetch(`/api/skills/markdown?${params.toString()}`, {
		signal,
	});

	if (!response.ok) {
		const data = (await response.json().catch(() => null)) as {
			error?: string;
		} | null;
		throw new Error(data?.error || "Failed to load markdown preview");
	}

	return (await response.json()) as MarkdownResponse;
}

function isMarkdownFile(fileName: string) {
	const lowerCaseName = fileName.toLowerCase();
	return (
		lowerCaseName.endsWith(".md") ||
		lowerCaseName.endsWith(".markdown") ||
		lowerCaseName.endsWith(".mdx")
	);
}

export function SkillMarkdownDialog({
	skillName,
	description,
	folderPath,
	files,
}: SkillMarkdownDialogProps) {
	const markdownFiles = useMemo(
		() => files.filter((file) => isMarkdownFile(file.name)),
		[files],
	);
	const [open, setOpen] = useState(false);
	const [selectedPath, setSelectedPath] = useState<string | null>(
		markdownFiles[0]?.relativePath ?? null,
	);
	const [contentByPath, setContentByPath] = useState<MarkdownContentMap>({});
	const [loading, setLoading] = useState(false);
	const [error, setError] = useState<string | null>(null);

	useEffect(() => {
		if (!selectedPath && markdownFiles[0]?.relativePath) {
			setSelectedPath(markdownFiles[0].relativePath);
		}
	}, [markdownFiles, selectedPath]);

	useEffect(() => {
		if (!open || markdownFiles.length === 0) {
			return;
		}

		const controller = new AbortController();

		async function loadMarkdownFiles() {
			setLoading(true);
			setError(null);

			try {
				const responses = await Promise.all(
					markdownFiles.map(async (file) => {
						return fetchMarkdownFile(
							folderPath,
							file.relativePath,
							controller.signal,
						);
					}),
				);

				if (controller.signal.aborted) {
					return;
				}

				setContentByPath(
					responses.reduce<MarkdownContentMap>((accumulator, item) => {
						accumulator[item.relativePath] = item.content;
						return accumulator;
					}, {}),
				);
			} catch (fetchError) {
				if (controller.signal.aborted) {
					return;
				}

				setContentByPath({});
				setError(
					fetchError instanceof Error
						? fetchError.message
						: "Failed to load markdown preview",
				);
			} finally {
				if (!controller.signal.aborted) {
					setLoading(false);
				}
			}
		}

		void loadMarkdownFiles();

		return () => {
			controller.abort();
		};
	}, [folderPath, markdownFiles, open]);

	const selectedContent = selectedPath
		? (contentByPath[selectedPath] ?? "")
		: "";

	if (markdownFiles.length === 0) {
		return null;
	}

	return (
		<Dialog open={open} onOpenChange={setOpen}>
			<DialogTrigger asChild>
				<Button variant="secondary" size="sm" className="flex-1 gap-2">
					<FileText className="w-4 h-4" />
					View Markdown
				</Button>
			</DialogTrigger>
			<DialogContent className="h-[92vh] w-[96vw] max-w-[96vw] grid-rows-[auto_1fr] gap-0 overflow-hidden p-0 sm:max-w-[96vw] lg:max-w-[1800px]">
				<div className="border-b px-6 py-4">
					<DialogHeader>
						<DialogTitle>{skillName}</DialogTitle>
						<DialogDescription>
							{description ||
								"Preview markdown files included in this skill package."}
						</DialogDescription>
					</DialogHeader>
				</div>
				<div className="min-h-0 grid md:grid-cols-[280px_minmax(0,1fr)]">
					<aside className="border-b md:border-r md:border-b-0 bg-muted/20 min-h-0 overflow-y-auto">
						<div className="p-3 space-y-1">
							{markdownFiles.map((file) => {
								const isActive = file.relativePath === selectedPath;

								return (
									<button
										key={file.relativePath}
										type="button"
										onClick={() => setSelectedPath(file.relativePath)}
										className={[
											"w-full rounded-md px-3 py-2 text-left text-sm",
											isActive
												? "bg-background shadow-sm border"
												: "hover:bg-background/70 text-muted-foreground",
										].join(" ")}
									>
										<div className="font-medium text-foreground truncate">
											{file.name}
										</div>
										<div className="text-xs truncate mt-1">
											{file.relativePath}
										</div>
									</button>
								);
							})}
						</div>
					</aside>
					<section className="min-h-0 overflow-y-auto">
						<div className="px-6 py-5">
							<div className="mb-4 border-b pb-3">
								<p className="text-sm text-muted-foreground">{selectedPath}</p>
							</div>

							{loading && Object.keys(contentByPath).length === 0 && (
								<div className="flex min-h-[220px] items-center justify-center text-sm text-muted-foreground gap-2">
									<LoaderCircle className="w-4 h-4 animate-spin" />
									Loading markdown...
								</div>
							)}

							{!loading && error && (
								<div className="rounded-lg border border-destructive/30 bg-destructive/5 px-4 py-3 text-sm text-destructive">
									{error}
								</div>
							)}

							{!error && selectedContent && (
								<pre className="overflow-x-auto whitespace-pre-wrap break-words text-sm leading-6 text-foreground">
									{selectedContent}
								</pre>
							)}
						</div>
					</section>
				</div>
			</DialogContent>
		</Dialog>
	);
}
