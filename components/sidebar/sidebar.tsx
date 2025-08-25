"use client";

import { GenericSidebarItem } from "./sidebar-item";

export type SidebarItem = {
	slug: string;
	name: string;
	count?: number;
	icon?: React.ReactNode;
	badge?: string;
};

export interface GenericSidebarProps {
	items: SidebarItem[];
	baseUrl: string;
	errorMessage?: string;
	emptyMessage?: string;
	title?: string;
	className?: string;
	itemClassName?: string;
	sortBy?: 'count' | 'name' | 'slug' | ((a: SidebarItem, b: SidebarItem) => number);
	showCount?: boolean;
	onItemClick?: (item: SidebarItem) => void;
}

export function GenericSidebar({
	items,
	baseUrl,
	errorMessage,
	emptyMessage = "No items found",
	title,
	className = "w-64 shrink-0 h-[calc(100vh-68px)] bg-background border-r border-border",
	itemClassName,
	sortBy = 'count',
	showCount = true,
	onItemClick
}: GenericSidebarProps) {
	// Sort items if needed
	const sortedItems = [...items];
	if (typeof sortBy === 'function') {
		sortedItems.sort(sortBy);
	} else {
		switch (sortBy) {
			case 'count':
				sortedItems.sort((a, b) => (b.count || 0) - (a.count || 0));
				break;
			case 'name':
				sortedItems.sort((a, b) => a.name.localeCompare(b.name));
				break;
			case 'slug':
				sortedItems.sort((a, b) => a.slug.localeCompare(b.slug));
				break;
		}
	}

	if (errorMessage) {
		return (
			<nav className={className}>
				<div className="p-4">
					<div className="text-destructive text-sm">
						<h3 className="font-bold mb-2">Error:</h3>
						<p>{errorMessage}</p>
					</div>
				</div>
			</nav>
		);
	}

	return (
		<nav className={className}>
			{title && (
				<div className="p-4 border-b border-border">
					<h2 className="font-semibold text-lg">{title}</h2>
				</div>
			)}
			
			{sortedItems.length > 0 ? (
				sortedItems.map((item) => (
					<GenericSidebarItem
						key={item.slug}
						item={item}
						baseUrl={baseUrl}
						showCount={showCount}
						className={itemClassName}
						onClick={onItemClick}
					/>
				))
			) : (
				<div className="p-4 text-muted-foreground text-sm">{emptyMessage}</div>
			)}
		</nav>
	);
} 