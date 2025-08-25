"use client";

import { usePathname } from "next/navigation";
import { Suspense } from "react";
import {
	ContextsMultiSelectSidebar,
	FilterGroup,
} from "./ContextsMultiSelectSidebar";

interface ContextsLayoutClientProps {
	children: React.ReactNode;
	filterGroups: FilterGroup[];
	error?: string;
}

export function ContextsLayoutClient({
	children,
	filterGroups,
	error,
}: ContextsLayoutClientProps) {
	const pathname = usePathname();
	const isMainContextsPage = pathname === "/contexts";

	if (isMainContextsPage) {
		// Show sidebar on main contexts page
		return (
			<main className="flex min-h-screen">
				<Suspense
					fallback={
						<div className="w-[280px] border-r min-h-screen">
							<div className="p-4">
								<h2 className="text-sm font-semibold">Filters</h2>
								<div className="space-y-4 mt-4">
									<div className="h-8 bg-muted animate-pulse rounded"></div>
									<div className="h-8 bg-muted animate-pulse rounded"></div>
									<div className="h-8 bg-muted animate-pulse rounded"></div>
									<div className="h-8 bg-muted animate-pulse rounded"></div>
								</div>
							</div>
						</div>
					}
				>
					<ContextsMultiSelectSidebar
						filterGroups={filterGroups}
						error={error}
					/>
				</Suspense>
				<div className="flex-1 overflow-auto">{children}</div>
			</main>
		);
	}

	// No sidebar on detail pages
	return <main className="min-h-screen">{children}</main>;
}
