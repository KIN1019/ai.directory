"use client";

import { useState, useEffect } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { Badge } from "@/components/ui/badge";

type Tag = {
	slug: string;
	name: string;
	count: number;
};

type McpMultiSelectSidebarProps = {
	tags: Tag[];
	error?: string;
};

export function McpMultiSelectSidebar({
	tags,
	error,
}: McpMultiSelectSidebarProps) {
	const router = useRouter();
	const searchParams = useSearchParams();
	const [selectedTags, setSelectedTags] = useState<string[]>([]);

	// Initialize selected tags from URL params
	useEffect(() => {
		const tagsParam = searchParams.get("tags");
		if (tagsParam) {
			setSelectedTags(tagsParam.split(",").filter(Boolean));
		}
	}, [searchParams]);

	const handleTagClick = (tagSlug: string) => {
		const isSelected = selectedTags.includes(tagSlug);
		const newSelectedTags = isSelected
			? selectedTags.filter((tag) => tag !== tagSlug)
			: [...selectedTags, tagSlug];

		setSelectedTags(newSelectedTags);

		// Update URL while preserving other parameters like dialog
		const params = new URLSearchParams(searchParams);
		if (newSelectedTags.length > 0) {
			params.set("tags", newSelectedTags.join(","));
		} else {
			params.delete("tags");
		}

		router.push(`/mcp?${params.toString()}`);
	};

	const clearAllTags = () => {
		setSelectedTags([]);
		// Preserve dialog parameter when clearing tags
		const params = new URLSearchParams(searchParams);
		params.delete("tags");
		const queryString = params.toString();
		router.push(`/mcp${queryString ? "?" + queryString : ""}`);
	};

	if (error) {
		return (
			<div className="w-[250px] border-r">
				<div className="p-4">
					<h2 className="text-lg font-semibold mb-4">MCP Tags</h2>
					<p className="text-red-500 text-sm">{error}</p>
				</div>
			</div>
		);
	}

	const sortedTags = [...tags].sort((a, b) => b.count - a.count);

	return (
		<div className="w-[250px] border-r h-screen">
			<div className="p-4">
				<div className="flex items-center justify-between mb-4">
					<h2 className="text-sm font-semibold ml-1">Tags</h2>
					{selectedTags.length > 0 && (
						<button
							onClick={clearAllTags}
							className="text-sm text-muted-foreground hover:text-foreground"
						>
							Clear all
						</button>
					)}
				</div>

				<div className="space-y-1">
					{sortedTags.map((tag) => {
						const isSelected = selectedTags.includes(tag.slug);
						return (
							<div
								key={tag.slug}
								onClick={() => handleTagClick(tag.slug)}
								className={`flex items-center justify-between p-2 rounded-md cursor-pointer transition-colors ${
									isSelected
										? "bg-primary text-primary-foreground"
										: "hover:bg-muted"
								}`}
							>
								<span className="text-sm">{tag.name}</span>
								<Badge
									variant={isSelected ? "outline" : "secondary"}
									className={`ml-2 ${isSelected ? "border-primary-foreground text-primary-foreground bg-transparent" : ""}`}
								>
									{tag.count}
								</Badge>
							</div>
						);
					})}
				</div>

				{selectedTags.length > 0 && (
					<div className="mt-4 pt-4 border-t">
						<h3 className="text-sm font-medium mb-2">Selected Tags:</h3>
						<div className="flex flex-wrap gap-1">
							{selectedTags.map((tagSlug) => {
								const tag = tags.find((t) => t.slug === tagSlug);
								return tag ? (
									<Badge key={tagSlug} variant="default" className="text-xs">
										{tag.name}
									</Badge>
								) : null;
							})}
						</div>
					</div>
				)}
			</div>
		</div>
	);
}
