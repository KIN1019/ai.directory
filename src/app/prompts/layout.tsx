import { Suspense } from "react";
import { RulesSidebar } from "./RulesSidebar";

export default function RulesLayout({
	children,
}: Readonly<{
	children: React.ReactNode;
}>) {
	return (
		<main className="flex min-h-screen">
			<Suspense
				fallback={
					<div className="w-[280px] border-r h-screen overflow-y-auto shrink-0">
						<div className="p-4">
							<h2 className="text-sm font-semibold mb-4">Filters</h2>
							<div className="space-y-4">
								<div className="h-8 bg-muted animate-pulse rounded"></div>
								<div className="h-8 bg-muted animate-pulse rounded"></div>
								<div className="h-8 bg-muted animate-pulse rounded"></div>
							</div>
						</div>
					</div>
				}
			>
				<RulesSidebar />
			</Suspense>
			<div className="flex-1 overflow-auto">{children}</div>
		</main>
	);
}
