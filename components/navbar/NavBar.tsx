import Link from "next/link";
import { SearchCommandDialog } from "../command/SearchCommandDialog";
import { NavMenu } from "./NavMenu";
import { ModeToggle } from "../ModeToggle";

function NavBar() {
	return (
		<nav className="flex flex-row items-center justify-between p-4 border-b sticky top-0 bg-background/80 backdrop-blur-sm z-50">
			<div className="font-mono">
				<Link href="/">dhpai.home</Link>
			</div>
			<div className="flex items-center justify-between gap-4">
				<NavMenu />
				<SearchCommandDialog />
				<ModeToggle />
			</div>
		</nav>
	);
}

export { NavBar };
