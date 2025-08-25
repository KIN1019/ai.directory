import { CommandInput } from "@/components/ui/command";
import { useState, useEffect, useMemo } from "react";
import {
	CommandDialog,
	CommandEmpty,
	CommandGroup,
	CommandItem,
	CommandList,
	CommandSeparator,
	CommandShortcut,
} from "@/components/ui/command";
import { useSelection } from "@/hooks/use-selection";

type Rule = {
	slug: string;
	title: string;
	description: string;
	tags: string[];
	content: string;
};

interface SearchRulesProps {
	searchQuery: string;
	onSelect?: (rule: Rule) => void;
}
function SearchRules(props: SearchRulesProps) {
	const [rules, setRules] = useState<Rule[]>([]);
	// Create local state to track the active item index
	const [activeIndex, setActiveIndex] = useState(0);
	// Keep track of whether rules have been loaded
	const [rulesLoaded, setRulesLoaded] = useState(false);

	useEffect(() => {
		fetch("/api/rules")
			.then((res) => res.json())
			.then((data) => {
				setRules(data);
				// Reset active index when rules are loaded
				setActiveIndex(0);
				setRulesLoaded(true);
			})
			.catch((err) => console.error("Failed to load rules:", err));
	}, []);
	
	// Reset active index when search query changes
	useEffect(() => {
		setActiveIndex(0);
	}, [props.searchQuery]);

	// Filter rules based on search query if present
	const filteredRules = props.searchQuery
		? rules.filter(rule => 
			rule.title.toLowerCase().includes(props.searchQuery.toLowerCase()) || 
			rule.content.toLowerCase().includes(props.searchQuery.toLowerCase()))
		: rules;

	// Handle keyboard navigation
	const handleKeyDown = (e: React.KeyboardEvent) => {
		if (filteredRules.length === 0) return;
		
		switch (e.key) {
			case "ArrowDown":
				e.preventDefault();
				setActiveIndex(prev => (prev + 1) % filteredRules.length);
				break;
			case "ArrowUp":
				e.preventDefault();
				setActiveIndex(prev => (prev - 1 + filteredRules.length) % filteredRules.length);
				break;
			case "Enter":
				if (props.onSelect && filteredRules[activeIndex]) {
					e.preventDefault();
					props.onSelect(filteredRules[activeIndex]);
				}
				break;
		}
	};

	// Make sure at least one item is always selected
	useEffect(() => {
		if (filteredRules.length > 0 && activeIndex >= filteredRules.length) {
			setActiveIndex(0);
		}
	}, [filteredRules, activeIndex]);

	// Force selection of the first item when rules are loaded
	useEffect(() => {
		if (rulesLoaded && filteredRules.length > 0) {
			// Use a short timeout to ensure the component has fully rendered
			const timeout = setTimeout(() => {
				setActiveIndex(0);
			}, 0);
			return () => clearTimeout(timeout);
		}
	}, [rulesLoaded, filteredRules.length]);

	return (
		<CommandList onKeyDown={handleKeyDown}>
			<CommandEmpty>No results found.</CommandEmpty>
			<CommandGroup>
				{filteredRules.map((rule, idx) => (
					<CommandItem 
						key={rule.slug}
						value={rule.slug}
						onSelect={() => {
							setActiveIndex(idx);
							if (props.onSelect) {
								props.onSelect(rule);
							}
						}}
						onMouseEnter={() => setActiveIndex(idx)}
						className={activeIndex === idx ? "bg-accent text-accent-foreground" : ""}
					>
						<span>{rule.title}</span>
					</CommandItem>
				))}
			</CommandGroup>
		</CommandList>
	)

	return (
		<div className="grid grid-cols-[250px_minmax(0,_1fr)] overflow-hidden sm:min-h-[700px]">
			<div className="overflow-y-scroll">
				<CommandList>
					<CommandEmpty>No results found.</CommandEmpty>
					<CommandGroup>
						{rules.map((rule, idx) => (
							<CommandItem key={rule.slug}>
								<span>{rule.title}</span>
							</CommandItem>
						))}
					</CommandGroup>
				</CommandList>
			</div>
			<div className="min-w-0">
				{/* {filteredRules[props.selectedIndex] ? (
					<>
						<h3 className="text-lg font-semibold">
							{filteredRules[props.selectedIndex].title}
						</h3>
						<p className="text-sm text-muted-foreground">
							{filteredRules[props.selectedIndex].description}
						</p>
						<pre className="mt-2 text-xs whitespace-pre-wrap max-h-[200px] overflow-auto">
							{filteredRules[props.selectedIndex].content.slice(0, 200) + "..."}
						</pre>
					</>
				) : (
					<p className="text-sm text-muted-foreground">No rule selected.</p>
				)} */}
			</div>
		</div>
	);
}

export { SearchRules };
