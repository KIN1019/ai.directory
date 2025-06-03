"use client";

import { useState } from "react";
import Image from "next/image";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Check, Copy, ExternalLink, FileCode, Info, Settings, Wrench } from "lucide-react";
import { cn } from "@/lib/utils";

type Tool = {
	name: string;
	description: string;
	[key: string]: unknown;
};

type McpDialogProps = {
	name: string;
	description: string;
	logo: string;
	tools: Tool[];
	href: string;
	setupCode: { type: "sse", url: string } | { type: "stdio", command: string };
};

type SetupStep = {
	id: string;
	title: string;
	icon: React.ElementType;
	completed?: boolean;
};

const setupSteps: SetupStep[] = [
	{ id: "overview", title: "Overview", icon: Info },
	{ id: "setup", title: "Setup Instructions", icon: Settings },
	{ id: "tools", title: "Available Tools", icon: Wrench },
];

type CopyButtonProps = {
	text: string;
	size?: "sm" | "default" | "lg";
	variant?: "default" | "outline" | "secondary" | "ghost" | "destructive";
	className?: string;
};

function CopyButton({ text, size = "sm", variant = "outline", className = "" }: CopyButtonProps) {
	const [copied, setCopied] = useState(false);

	const handleCopy = async () => {
		try {
			await navigator.clipboard.writeText(text);
			setCopied(true);
			setTimeout(() => setCopied(false), 2000);
		} catch (err) {
			console.error('Failed to copy text:', err);
		}
	};

	return (
		<Button
			variant={variant}
			size={size}
			onClick={handleCopy}
			className={`gap-2 ${className}`}
		>
			<Copy className="w-4 h-4" />
			{copied ? "Copied!" : "Copy"}
		</Button>
	);
}

function McpDialogMain({ name, description, logo, tools, href, setupCode }: McpDialogProps) {
	const [currentStep, setCurrentStep] = useState("overview");
	const [selectedEditor, setSelectedEditor] = useState<"vscode" | "cursor">("vscode");

	const renderStepContent = () => {
		switch (currentStep) {
			case "overview":
				return (
					<div className="flex flex-col items-center justify-center h-full p-8 text-center overflow-y-auto">
						<div className="mb-6">
							<Image 
								src={logo} 
								alt={name} 
								width={48}
								height={48}
								className="rounded object-cover" 
							/>
						</div>
						<h2 className="text-xl font-bold mb-4">{name}</h2>
						<p className="text-sm text-muted-foreground max-w-2xl leading-relaxed">
							{description}
						</p>
						<div className="mt-8 flex gap-4">
							<Button 
								onClick={() => setCurrentStep("setup")}
								className="gap-2"
							>
								<Settings className="w-4 h-4" />
								Get Started
							</Button>
							<Button variant="outline" asChild className="gap-2">
								<a href={href} target="_blank" rel="noopener noreferrer">
									<ExternalLink className="w-4 h-4" />
									View Documentation
								</a>
							</Button>
						</div>
					</div>
				);

			case "setup":
				const setupConfigVSCode = {
					"mcpServers": {
						[name.toLowerCase().replace(/\s+/g, '-')]: setupCode
					}
				};

				const setupConfigCursor = {
					"mcp": {
						"servers": {
							[name.toLowerCase().replace(/\s+/g, '-')]: setupCode
						}
					}
				};

				const vscodeCLICommand = setupCode.type === "sse"
					? `code --add-mcp '{"name":"${name.toLowerCase().replace(/\s+/g, '-')}","url":["${setupCode.url}"]}'`
					: `code --add-mcp '{"name":"${name.toLowerCase().replace(/\s+/g, '-')}","command":"${setupCode.command.split(" ")[0]}","args":["${setupCode.command.split(" ").slice(1).join('","')}"]}'`;

				return (
					<div className="h-full overflow-y-auto">
						<div className="p-6 space-y-6">
							<div>
								<h3 className="text-md font-semibold mb-2">Setup Instructions</h3>
								<p className="text-muted-foreground mb-6 text-sm">
									Add the following configuration to your editor settings to enable this MCP server.
								</p>
							</div>

							<div className="space-y-4">
								<div className="flex border-b">
									<button
										onClick={() => setSelectedEditor("vscode")}
										className={`px-4 py-2 text-sm font-medium border-b-2 transition-colors ${
											selectedEditor === "vscode"
												? "border-primary text-primary"
												: "border-transparent text-muted-foreground hover:text-foreground"
										}`}
									>
										VSCode
									</button>
									<button
										onClick={() => setSelectedEditor("cursor")}
										className={`px-4 py-2 text-sm font-medium border-b-2 transition-colors ${
											selectedEditor === "cursor"
												? "border-primary text-primary"
												: "border-transparent text-muted-foreground hover:text-foreground"
										}`}
									>
										Cursor
									</button>
								</div>

								{selectedEditor === "vscode" && (
									<div className="space-y-4">
										<div className="bg-muted/50 rounded-lg p-4 flex gap-4 flex-col">
											<div>
												<div className="flex flex-row items-center gap-4 justify-between mb-2">
													<p className="text-sm text-muted-foreground">
														Install the MCP server using the VS Code CLI
													</p>
													<CopyButton text={vscodeCLICommand} />
												</div>
												<pre className="bg-background border rounded p-3 text-xs overflow-x-auto h-fit overflow-y-auto">
													<code>{vscodeCLICommand}</code>
												</pre>
											</div>
											<div>
												<div className="flex flex-row items-center gap-4 justify-between mb-2">
													<p className="text-sm text-muted-foreground">
														Or add to your VSCode settings.json:
													</p>
													<CopyButton text={JSON.stringify(setupConfigVSCode, null, 2)} />
												</div>
												<pre className="bg-background border rounded p-3 text-xs overflow-x-auto h-fit overflow-y-auto">
													<code>{JSON.stringify(setupConfigVSCode, null, 2)}</code>
												</pre>
											</div>
										</div>
									</div>
								)}

								{selectedEditor === "cursor" && (
									<div className="space-y-4">
										<div className="bg-muted/50 rounded-lg p-4">
											<div className="flex flex-row items-center gap-4 justify-between mb-2">
												<p className="text-sm text-muted-foreground">
													Add to your Cursor settings:
												</p>
												<CopyButton text={JSON.stringify(setupConfigCursor, null, 2)} />
											</div>
											<pre className="bg-background border rounded p-3 text-xs overflow-x-auto h-fit overflow-y-auto">
												<code>{JSON.stringify(setupConfigCursor, null, 2)}</code>
											</pre>
										</div>
									</div>
								)}
							</div>

							{setupCode.type === "stdio" && (
								<div className="bg-blue-50 dark:bg-blue-950/30 border border-blue-200 dark:border-blue-800 rounded-lg p-4">
									<h5 className="font-medium text-blue-900 dark:text-blue-100 mb-2">Note for stdio setup:</h5>
									<p className="text-sm text-blue-800 dark:text-blue-200">
										Make sure the command <code className="bg-blue-100 dark:bg-blue-900 px-1 rounded">{setupCode.command}</code> is available in your PATH.
									</p>
								</div>
							)}
						</div>
					</div>
				);

			case "tools":
				return (
					<div className="h-full overflow-y-auto">
						<div className="p-6">
							<div className="mb-6">
								<h3 className="text-md font-semibold mb-2">Available Tools</h3>
								<p className="text-muted-foreground text-sm">
									This MCP provides {tools.length} tool{tools.length !== 1 ? 's' : ''} for integration.
								</p>
							</div>

							<div className="grid gap-4">
								{tools.map((tool, index) => (
									<div key={index} className="border rounded-lg p-4 hover:bg-muted/50 transition-colors">
										<div className="flex items-start justify-between">
											<div className="flex-1">
												<h4 className="font-medium mb-1 text-sm">{tool.name}</h4>
												<p className="text-xs text-muted-foreground">{tool.description}</p>
											</div>
											<Badge variant="outline" className="ml-4 shrink-0">
												Tool
											</Badge>
										</div>
									</div>
								))}
							</div>

							{tools.length === 0 && (
								<div className="text-center py-8 text-muted-foreground">
									<Wrench className="w-12 h-12 mx-auto mb-3 opacity-50" />
									<p>No tools available for this MCP</p>
								</div>
							)}
						</div>
					</div>
				);

			default:
				return null;
		}
	};

	return (
		<div className="flex h-[400px] w-full max-h-[600px] overflow-hidden">
			<nav className="w-64 border-r pr-4 flex flex-col shrink-0">
				<div className="space-y-2 flex-1 overflow-y-auto">
					{setupSteps.map((step, index) => (
						<button
							key={step.id}
							onClick={() => setCurrentStep(step.id)}
							className={cn(
								"w-full flex items-center gap-3 p-3 rounded-lg text-left transition-colors",
								currentStep === step.id
									? "text-primary"
									: "text-muted-foreground hover:text-foreground"
							)}
						>
							<step.icon className="w-5 h-5" />
							<span className="text-xs font-medium">{step.title}</span>
						</button>
					))}
				</div>
			</nav>

			<main className="flex-1 flex flex-col min-w-0 overflow-hidden">
				<div className="flex-1 overflow-y-auto max-h-[400px]">
					{renderStepContent()}
				</div>
			</main>
		</div>
	);
}

function McpDialogSetup(props: McpDialogProps) {
	return (
		<div className="p-6">
			<McpDialogMain {...props} />
		</div>
	);
}

export { McpDialogMain, McpDialogSetup, type McpDialogProps };