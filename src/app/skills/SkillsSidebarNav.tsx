"use client";

import { useRouter, usePathname, useSearchParams } from "next/navigation";
import { Badge } from "@/components/ui/badge";
import { getSkillSourceLabel } from "@/lib/skill-source-map";

type SkillsSource = {
	name: string;
	count: number;
};

type SkillsSidebarNavProps = {
	readonly sources: SkillsSource[];
};

export function SkillsSidebarNav({ sources }: SkillsSidebarNavProps) {
	const router = useRouter();
	const pathname = usePathname();
	const searchParams = useSearchParams();
	const selectedSource = searchParams.get("source");

	function handleSelect(sourceName: string | null) {
		const params = new URLSearchParams(searchParams.toString());
		if (sourceName) {
			params.set("source", sourceName);
		} else {
			params.delete("source");
		}
		router.push(`${pathname}?${params.toString()}`);
	}

	const totalCount = sources.reduce((sum, s) => sum + s.count, 0);

	return (
		<div className="w-[280px] border-r h-screen overflow-y-auto shrink-0 sticky top-[57px]">
			<div className="p-4">
				<h2 className="text-sm font-semibold mb-4">Repositories</h2>
				<div className="space-y-1">
					<button
						type="button"
						onClick={() => handleSelect(null)}
						className={`flex items-center justify-between w-full px-3 py-2 rounded-md text-sm transition-colors cursor-pointer ${
							!selectedSource
								? "bg-secondary font-medium"
								: "hover:bg-secondary/50 text-muted-foreground"
						}`}
					>
						<span>All</span>
						<Badge variant="secondary" className="text-xs">
							{totalCount}
						</Badge>
					</button>
					{sources.map((source) => (
						<button
							key={source.name}
							type="button"
							onClick={() => handleSelect(source.name)}
							className={`flex items-center justify-between w-full px-3 py-2 rounded-md text-sm transition-colors cursor-pointer ${
								selectedSource === source.name
									? "bg-secondary font-medium"
									: "hover:bg-secondary/50 text-muted-foreground"
							}`}
						>
							<span className="truncate text-left">
								{getSkillSourceLabel(source.name)}
							</span>
							<Badge variant="secondary" className="text-xs shrink-0 ml-2">
								{source.count}
							</Badge>
						</button>
					))}
				</div>
			</div>
		</div>
	);
}
