"use client";

import { usePathname } from "next/navigation";

interface RulesSidebarItemProps {
	children: React.ReactNode;
	slug: string;
	count: number;
}

export function RulesSidebarItem(props: RulesSidebarItemProps) {
	const pathname = usePathname();
	const isCurrentPage = pathname.startsWith(`/prompts/${props.slug}`);

	return (
		<a
			href={`/prompts/${props.slug}`}
			className={`flex justify-between px-6 py-3 cursor-pointer hover:bg-secondary transition duration-150 font-medium text-sm ${!isCurrentPage ? "opacity-30" : ""}`}
		>
			<span>{props.children}</span>
			<span>{props.count}</span>
		</a>
	);
}
