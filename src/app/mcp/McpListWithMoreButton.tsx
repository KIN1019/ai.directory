"use client";

import { useState } from "react";
import { McpCardWithDialog } from "./McpCard";
import { Button } from "@/components/ui/button";
import { ChevronDown, ChevronUp } from "lucide-react";

type McpDocument = {
	name: string;
	description: string;
	logo: string;
	tools: Array<{
		name: string;
		description: string;
	}>;
	setupCode:
		| { type: "sse"; url: string }
		| {
				type: "stdio";
				command: string;
				args: string[];
				env: { [key: string]: string };
		  };
	href: string;
	fileName: string;
	setupDescription?: string;
	slug?: string;
	hidden?: boolean;
};

interface McpListWithMoreButtonProps {
	mcps: McpDocument[];
	openDialog: string | null;
}

export function McpListWithMoreButton({
	mcps,
	openDialog,
}: McpListWithMoreButtonProps) {
	const [showHidden, setShowHidden] = useState(false);

	// Separate visible and hidden MCPs
	const visibleMcps = mcps.filter((mcp) => !mcp.hidden);
	const hiddenMcps = mcps.filter((mcp) => mcp.hidden);

	const renderMcp = (mcp: McpDocument) => {
		const mcpSlug = mcp.fileName.replace(".yaml", "");
		return (
			<McpCardWithDialog
				key={mcp.fileName}
				name={mcp.name}
				description={mcp.description}
				logo={mcp.logo}
				tools={mcp.tools}
				setupCode={mcp.setupCode}
				href={mcp.href}
				fileName={mcp.fileName}
				open={openDialog === mcpSlug}
				setupDescription={mcp.setupDescription}
				slug={mcp.slug}
			/>
		);
	};

	return (
		<div className="space-y-6">
			{/* Visible MCPs */}
			{visibleMcps.length > 0 && (
				<div className="grid grid-cols-1 xl:grid-cols-2 2xl:grid-cols-3 gap-6">
					{visibleMcps.map(renderMcp)}
				</div>
			)}

			{/* Hidden MCPs section */}
			{hiddenMcps.length > 0 && (
				<div className="space-y-4">
					{/* More button */}
					<div className="flex justify-center">
						<Button
							variant="outline"
							onClick={() => setShowHidden(!showHidden)}
							className="flex items-center gap-2"
						>
							{showHidden ? (
								<>
									Show Less
									<ChevronUp className="h-4 w-4" />
								</>
							) : (
								<>
									More ({hiddenMcps.length})
									<ChevronDown className="h-4 w-4" />
								</>
							)}
						</Button>
					</div>

					{/* Hidden MCPs grid */}
					{showHidden && (
						<div className="grid grid-cols-1 xl:grid-cols-2 2xl:grid-cols-3 gap-6">
							{hiddenMcps.map(renderMcp)}
						</div>
					)}
				</div>
			)}
		</div>
	);
}
