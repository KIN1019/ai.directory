import { CommandDialog } from "../ui/command";
import {
	CommandEmpty,
	CommandGroup,
	CommandItem,
	CommandList,
	CommandSeparator,
	CommandShortcut,
	CommandInput,
} from "@/components/ui/command";
import { ScrollText, FileCheck2, Blocks } from "lucide-react";

interface CommandRootProps {
	setMode: (mode: "root" | "rules") => void;
}

function CommandRoot(props: CommandRootProps) {
	return (
		<CommandList>
			<CommandEmpty>No results found.</CommandEmpty>
			<CommandGroup heading="Suggestions">
				<CommandItem onSelect={() => props.setMode("rules")}>
					<FileCheck2 />
					<span>Search Rules</span>
				</CommandItem>
				<CommandItem>
					<ScrollText />
					<span>
						Search Contexts
					</span>
				</CommandItem>
				<CommandItem>
					<Blocks />
					<span>Search MCPs</span>
				</CommandItem>
			</CommandGroup>
		</CommandList>
	);
}

export { CommandRoot };
