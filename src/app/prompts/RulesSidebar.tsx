import { getRulesSidebarSections } from "./rules-data";
import { RulesSidebarNav } from "./RulesSidebarNav";

async function RulesSidebar() {
	const sections = await getRulesSidebarSections();

	return <RulesSidebarNav sections={sections} />;
}

export { RulesSidebar };
