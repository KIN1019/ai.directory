"use client";

import { usePathname } from "next/navigation";
import type { SidebarItem } from "./sidebar";

export interface GenericSidebarItemProps {
	item: SidebarItem;
	baseUrl: string;
	showCount?: boolean;
	className?: string;
	onClick?: (item: SidebarItem) => void;
}

export function GenericSidebarItem({
	item,
	baseUrl,
	showCount = true,
	className,
	onClick
}: GenericSidebarItemProps) {
	const pathname = usePathname();
	const itemUrl = `${baseUrl}/${item.slug}`;
	
	// More precise path matching - check if pathname exactly matches or starts with itemUrl followed by a slash
	const isCurrentPage = pathname === itemUrl || pathname.startsWith(`${itemUrl}/`);

	const handleClick = (e: React.MouseEvent) => {
		if (onClick) {
			e.preventDefault();
			onClick(item);
		}
	};

	return (
		<a
			href={itemUrl}
			onClick={handleClick}
			className={`flex justify-between items-center px-6 py-3 cursor-pointer hover:bg-secondary transition duration-150 font-medium text-sm ${!isCurrentPage ? "opacity-30" : ""} ${className || ""}`}
		>
			<div className="flex items-center gap-2">
				{item.icon && <span className="shrink-0">{item.icon}</span>}
				<span>{item.name}</span>
			</div>
			
			<div className="flex items-center gap-2">
				{item.badge && (
					<span className="px-2 py-1 text-xs bg-muted text-muted-foreground rounded">
						{item.badge}
					</span>
				)}
				{showCount && item.count !== undefined && (
					<span className="text-muted-foreground">{item.count}</span>
				)}
			</div>
		</a>
	);
} 