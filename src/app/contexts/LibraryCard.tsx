"use client";

import {
	Card,
	CardContent,
	CardDescription,
	CardHeader,
	CardTitle,
} from "@/components/ui/card";
import { ExternalLink, Github, LucideIcon } from "lucide-react";
import { useRouter } from "next/navigation";

export interface LibraryData {
	name: string;
	description: string;
	slug: string;
	source?: string;
	lastUpdated?: string;
	llmsTxtUrl?: string;
	techStacks?: string[];
	teams?: string[];
	categories?: string[];
}

interface LibraryCardProps {
	library: LibraryData;
}

interface MetaItemProps {
	icon?: LucideIcon;
	children: React.ReactNode;
}

function MetaItem({ icon: Icon, children }: MetaItemProps) {
	return (
		<div className="flex items-center gap-1">
			{Icon && <Icon className="w-3 h-3" />}
			{children}
		</div>
	);
}

export function LibraryCard({ library }: LibraryCardProps) {
	const router = useRouter();

	const handleClick = () => {
		router.push(`/contexts/${library.slug}`);
	};

	const formatDate = (dateString?: string) => {
		if (!dateString) return "N/A";
		try {
			return new Date(dateString).toLocaleDateString("en-US", {
				year: "numeric",
				month: "short",
				day: "numeric",
			});
		} catch {
			return dateString;
		}
	};

	const renderSource = (source?: string) => {
		if (!source) return null;

		if (source.startsWith("/")) {
			const githubUrl = `https://github.com${source}`;
			return (
				<a
					href={githubUrl}
					target="_blank"
					rel="noopener noreferrer"
					onClick={(e) => e.stopPropagation()}
					className="flex items-center gap-1 text-teal-600 hover:text-teal-800 dark:text-teal-400 dark:hover:text-teal-300"
				>
					<Github className="w-3 h-3" />
					<span className="text-xs">{source}</span>
					<ExternalLink className="w-2.5 h-2.5" />
				</a>
			);
		}

		if (source.startsWith("http://") || source.startsWith("https://")) {
			return (
				<a
					href={source}
					target="_blank"
					rel="noopener noreferrer"
					onClick={(e) => e.stopPropagation()}
					className="flex items-center gap-1 text-teal-600 hover:text-teal-800 dark:text-teal-400 dark:hover:text-teal-300"
				>
					<ExternalLink className="w-3 h-3" />
					<span className="text-xs truncate max-w-[150px]" title={source}>
						{source.replace(/^https?:\/\//, "")}
					</span>
				</a>
			);
		}

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
				<CardTitle className="text-lg">{library.name}</CardTitle>
				<CardDescription className="h-10 overflow-hidden">
					{library.description}
				</CardDescription>
			</CardHeader>
			<CardContent className="space-y-3">
				{/* Source Information */}
				{library.source && (
					<div className="text-sm text-muted-foreground">
						<MetaItem>{renderSource(library.source)}</MetaItem>
					</div>
				)}
			</CardContent>
		</Card>
	);
}
