"use client";

import { usePathname, useRouter, useSearchParams } from "next/navigation";
import { useEffect, useState } from "react";
import { Badge } from "@/components/ui/badge";
import { Separator } from "@/components/ui/separator";
import { ChevronDown, ChevronRight, X } from "lucide-react";

type RulesSidebarTag = {
	slug: string;
	name: string;
	count: number;
};

type RulesSidebarSection = {
	key: string;
	title: string;
	count: number;
	items: RulesSidebarTag[];
};

type RulesSidebarNavProps = {
	readonly sections: RulesSidebarSection[];
};

function getSectionPath(sectionKey: string) {
	return `/prompts/${sectionKey}`;
}

function getCurrentSectionKey(
	pathname: string,
	sections: RulesSidebarSection[],
) {
	const [, promptsRoot, sectionKey] = pathname.split("/");

	if (promptsRoot !== "prompts") {
		return sections[0]?.key ?? "instructions";
	}

	return (
		sections.find((section) => section.key === sectionKey)?.key ??
		sections[0]?.key ??
		"instructions"
	);
}

function getPathSelectedFilters(
	pathname: string,
	sections: RulesSidebarSection[],
) {
	const segments = pathname.split("/").filter(Boolean);
	if (segments[0] !== "prompts") {
		return {} as Record<string, string[]>;
	}

	const section = sections.find((item) => item.key === segments[1]);
	if (!section) {
		return {} as Record<string, string[]>;
	}

	const candidate = segments[2];
	if (!candidate || !section.items.some((item) => item.slug === candidate)) {
		return {} as Record<string, string[]>;
	}

	return { [section.key]: [candidate] };
}

export function RulesSidebarNav(props: RulesSidebarNavProps) {
	const router = useRouter();
	const pathname = usePathname();
	const searchParams = useSearchParams();
	const currentSectionKey = getCurrentSectionKey(pathname, props.sections);
	const [selectedFilters, setSelectedFilters] = useState<
		Record<string, string[]>
	>({});
	const [expandedGroups, setExpandedGroups] = useState<string[]>([]);
	const [isInitialized, setIsInitialized] = useState(false);

	useEffect(() => {
		const filters: Record<string, string[]> = {};

		props.sections.forEach((section) => {
			const param = searchParams.get(section.key);
			if (param) {
				filters[section.key] = param.split(",").filter(Boolean);
			}
		});

		const pathSelectedFilters = getPathSelectedFilters(
			pathname,
			props.sections,
		);
		Object.entries(pathSelectedFilters).forEach(([key, values]) => {
			if (!filters[key]) {
				filters[key] = values;
			}
		});

		setSelectedFilters(filters);

		if (!isInitialized) {
			setExpandedGroups(Object.keys(filters));
			setIsInitialized(true);
		}
	}, [isInitialized, pathname, props.sections, searchParams]);

	const updateFilters = (
		updatedFilters: Record<string, string[]>,
		sectionKey: string,
	) => {
		const params = new URLSearchParams(searchParams.toString());

		props.sections.forEach((section) => {
			const values = updatedFilters[section.key] ?? [];
			if (values.length > 0) {
				params.set(section.key, values.join(","));
			} else {
				params.delete(section.key);
			}
		});

		const nextPath = getSectionPath(sectionKey);
		const nextQuery = params.toString();
		router.push(nextQuery ? `${nextPath}?${nextQuery}` : nextPath);
	};

	const handleFilterClick = (sectionKey: string, itemSlug: string) => {
		const currentFilters = selectedFilters[sectionKey] ?? [];
		const isSelected = currentFilters.includes(itemSlug);
		const nextFilters = isSelected
			? currentFilters.filter((value) => value !== itemSlug)
			: [...currentFilters, itemSlug];
		const updatedFilters = {
			...selectedFilters,
			[sectionKey]: nextFilters,
		};

		if (nextFilters.length === 0) {
			delete updatedFilters[sectionKey];
		}

		setSelectedFilters(updatedFilters);
		updateFilters(updatedFilters, sectionKey);
	};

	const clearAllFilters = () => {
		setSelectedFilters({});
		router.push(getSectionPath(currentSectionKey));
	};

	const toggleGroup = (groupKey: string) => {
		setExpandedGroups((prev) =>
			prev.includes(groupKey)
				? prev.filter((group) => group !== groupKey)
				: [...prev, groupKey],
		);
	};

	const totalSelectedFilters = Object.values(selectedFilters).flat().length;

	return (
		<aside
			id="prompts-sidebar"
			className="w-[280px] border-r h-screen overflow-y-auto shrink-0"
		>
			<div className="p-4">
				<div className="flex items-center justify-between mb-4">
					<h2 className="text-sm font-semibold">Filters</h2>
					{totalSelectedFilters > 0 && (
						<button
							type="button"
							onClick={clearAllFilters}
							className="text-sm text-muted-foreground hover:text-foreground flex items-center gap-1"
						>
							Clear all
							<X className="w-3 h-3" />
						</button>
					)}
				</div>

				<div className="space-y-4">
					{props.sections.map((section) => {
						const isExpanded = expandedGroups.includes(section.key);
						const selectedCount = (selectedFilters[section.key] ?? []).length;

						return (
							<div key={section.key}>
								<button
									type="button"
									onClick={() => toggleGroup(section.key)}
									className="flex items-center justify-between w-full text-left mb-2 hover:text-foreground transition-colors"
									aria-label={`${isExpanded ? "Collapse" : "Expand"} ${section.title}`}
								>
									<span className="text-sm font-medium flex items-center gap-1">
										{isExpanded ? (
											<ChevronDown className="w-4 h-4" />
										) : (
											<ChevronRight className="w-4 h-4" />
										)}
										{section.title}
									</span>
									<div className="min-w-[24px] flex justify-end items-center">
										{selectedCount > 0 && (
											<Badge
												variant="secondary"
												className="text-xs h-5 min-w-[20px] flex items-center justify-center"
											>
												{selectedCount}
											</Badge>
										)}
									</div>
								</button>

								{isExpanded && section.items.length > 0 && (
									<div className="space-y-1 ml-4">
										{section.items.map((item) => {
											const isItemActive = (
												selectedFilters[section.key] ?? []
											).includes(item.slug);

											return (
												<button
													key={`${section.key}-${item.slug}`}
													type="button"
													onClick={() =>
														handleFilterClick(section.key, item.slug)
													}
													className={`flex items-center justify-between p-2 rounded-md cursor-pointer transition-colors text-sm ${
														isItemActive
															? "bg-teal-800 text-white"
															: "hover:bg-muted"
													}`}
												>
													<span>{item.name}</span>
												</button>
											);
										})}
									</div>
								)}
							</div>
						);
					})}
				</div>

				{totalSelectedFilters > 0 && (
					<>
						<Separator className="my-4" />
						<div>
							<h3 className="text-sm font-medium mb-2">
								Active Filters ({totalSelectedFilters})
							</h3>
							<div className="flex flex-wrap gap-1">
								{Object.entries(selectedFilters).map(([groupKey, filters]) => {
									const group = props.sections.find(
										(section) => section.key === groupKey,
									);

									return filters.map((filterSlug) => {
										const filter = group?.items.find(
											(item) => item.slug === filterSlug,
										);

										return filter ? (
											<Badge
												key={`${groupKey}-${filterSlug}`}
												variant="default"
												className="text-xs cursor-pointer bg-teal-800 text-white hover:bg-teal-800"
												onClick={() => handleFilterClick(groupKey, filterSlug)}
											>
												{filter.name}
												<X className="w-3 h-3 ml-1" />
											</Badge>
										) : null;
									});
								})}
							</div>
						</div>
					</>
				)}
			</div>
		</aside>
	);
}
