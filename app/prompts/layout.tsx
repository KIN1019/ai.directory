import { RulesSidebar } from "@/components/rules/RulesSidebar";

export default function RulesLayout({
	children,
}: Readonly<{
	children: React.ReactNode;
}>) {
	return (
		<main className="flex flex-row">
			<RulesSidebar />
			{children}
		</main>
	);
}
