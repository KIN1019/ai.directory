"use client";

import { useState, useRef, useEffect } from "react";
import Image from "next/image";
import ReactMarkdown from "react-markdown";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Check, Copy, ExternalLink, FileCode, Info, Settings, Wrench, Search } from "lucide-react";
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
	setupCode:
		| { type: "sse", url: string }
		| { type: "stdio", command: string, args: string[], env: { [key: string]: string } };
	setupDescription?: string;
	slug?: string;
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

function McpDialogMain({ name, description, logo, tools, href, setupCode, setupDescription, slug }: McpDialogProps) {
	const [currentStep, setCurrentStep] = useState("overview");
	const [selectedEditor, setSelectedEditor] = useState<"vscode" | "cursor">("vscode");
	const [inputValues, setInputValues] = useState<Record<string, string>>({});
	const [toolsSearch, setToolsSearch] = useState("");
	const [showScrollGlow, setShowScrollGlow] = useState(false);
	const toolsScrollRef = useRef<HTMLDivElement>(null);

	// Extract input field requirements from env variables
	const getInputFields = () => {
		if (setupCode.type !== "stdio") return [];
	
		const inputFields: Array<{ key: string; label: string; source: string; defaultValue?: string }> = [];
		const foundKeys = new Set<string>();
	
		// Helper to extract key and default from pattern
		const extractInput = (str: string) => {
			const match = str.match(/^\$\{input:([^}]+)\}(?:\[([^\]]*)\])?$/);
			if (match) {
				return { key: match[1], defaultValue: match[2] };
			}
			return null;
		};
	
		// Check env
		if (setupCode.env) {
			Object.entries(setupCode.env).forEach(([envKey, value]) => {
				const result = extractInput(value);
				if (result && !foundKeys.has(result.key)) {
					const label = result.key.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase());
					inputFields.push({ key: result.key, label, source: 'env', defaultValue: result.defaultValue });
					foundKeys.add(result.key);
				}
			});
		}
	
		// Check args
		if (setupCode.args) {
			setupCode.args.forEach((arg) => {
				const result = extractInput(arg);
				if (result && !foundKeys.has(result.key)) {
					const label = result.key.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase());
					inputFields.push({ key: result.key, label, source: 'args', defaultValue: result.defaultValue });
					foundKeys.add(result.key);
				}
			});
		}
	
		return inputFields;
	};

	const inputFields = getInputFields();

	// Substitute input values in env object
	const getProcessedEnv = () => {
		if (setupCode.type !== "stdio" || !setupCode.env) return {};
		
		const processedEnv: Record<string, string> = {};
		
		Object.entries(setupCode.env).forEach(([envKey, value]) => {
			const match = value.match(/^\$\{input:([^}]+)\}$/);
			if (match) {
				const inputKey = match[1];
				processedEnv[envKey] = inputValues[inputKey] || `[Enter ${inputKey.replace(/_/g, ' ')}]`;
			} else {
				processedEnv[envKey] = value;
			}
		});
		
		return processedEnv;
	};

	// Clean up escaped characters in args (e.g., \@ becomes @)
	const getProcessedArgs = () => {
		if (setupCode.type !== "stdio" || !setupCode.args) return [];
		
		return setupCode.args.map(arg => 
			arg.replace(/\\@/g, '@').replace(/\\\\/g, '\\')
		);
	};

	// Handle scroll for tools container to show/hide glow effect
	const handleToolsScroll = () => {
		const container = toolsScrollRef.current;
		if (!container) return;

		const { scrollTop, scrollHeight, clientHeight } = container;
		const isAtBottom = scrollTop + clientHeight >= scrollHeight - 10; // 10px threshold
		setShowScrollGlow(!isAtBottom && scrollHeight > clientHeight);
	};

	// Set up scroll listener for tools container
	useEffect(() => {
		const container = toolsScrollRef.current;
		if (!container) return;

		// Initial check
		handleToolsScroll();

		container.addEventListener('scroll', handleToolsScroll);
		
		// Also check when content changes (search results)
		const resizeObserver = new ResizeObserver(handleToolsScroll);
		resizeObserver.observe(container);

		return () => {
			container.removeEventListener('scroll', handleToolsScroll);
			resizeObserver.disconnect();
		};
	}, [currentStep, toolsSearch]); // Re-run when step changes or search changes

	// Use slug if available, otherwise fallback to transformed name
	const configName = slug || name.toLowerCase().replace(/\s+/g, '-');

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
						[configName]: setupCode.type === "sse" 
							? setupCode 
							: {
								type: "stdio",
								command: setupCode.command,
								args: getProcessedArgs(),
								...(setupCode.env && Object.keys(setupCode.env).length > 0 && { env: getProcessedEnv() })
							}
					}
				};

				const setupConfigCursor = {
					"mcp": {
						"servers": {
							[configName]: setupCode.type === "sse" 
								? setupCode 
								: {
									type: "stdio",
									command: setupCode.command,
									args: getProcessedArgs(),
									...(setupCode.env && Object.keys(setupCode.env).length > 0 && { env: getProcessedEnv() })
								}
						}
					}
				};

				const vscodeCLICommand = setupCode.type === "sse"
					? `code --add-mcp '{"name":"${configName}","url":["${setupCode.url}"]}'`
					: `code --add-mcp '{"name":"${configName}","command":"${setupCode.command}","args":${JSON.stringify(getProcessedArgs())}${setupCode.env && Object.keys(setupCode.env).length > 0 ? `,"env":${JSON.stringify(getProcessedEnv())}` : ""}}'`;

				return (
					<div className="h-full overflow-y-auto">
						<div className="p-6 space-y-6">
							<div>
								<h3 className="text-md font-semibold mb-2">Setup Instructions</h3>
								<p className="text-muted-foreground mb-6 text-sm">
									Add the following configuration to your editor settings to enable this MCP server.
								</p>
							</div>

							{setupDescription && (
								<div className="bg-muted/30 border border-muted rounded-lg p-4 mb-6">
									<h4 className="text-sm font-medium mb-3">Additional Setup Notes</h4>
									<div className="text-sm">
										<ReactMarkdown
											components={{
												p: ({children}) => <p className="mb-2 last:mb-0">{children}</p>,
												ul: ({children}) => <div className="mb-2 space-y-1">{children}</div>,
												li: ({children}) => (
													<div className="text-sm flex items-start gap-2">
														<span className="text-muted-foreground mt-1 flex-shrink-0">•</span>
														<span>{children}</span>
													</div>
												),
												a: ({href, children}) => (
													<a 
														href={href} 
														target="_blank" 
														rel="noopener noreferrer"
														className="text-primary underline"
													>
														{children}
													</a>
												),
												code: ({children}) => (
													<code className="bg-muted px-1 py-0.5 rounded text-xs">
														{children}
													</code>
												),
											}}
										>
											{setupDescription}
										</ReactMarkdown>
									</div>
								</div>
							)}

							{inputFields.length > 0 && (
								<div className="space-y-4">
									<h4 className="text-sm font-medium">Required Configuration</h4>
									<div className="grid gap-4">
										{inputFields.map((field) => (
											<div key={field.key} className="space-y-2">
												<Label htmlFor={field.key} className="text-sm font-medium">
													{field.label}
												</Label>
												<Input
													id={field.key}
													type={field.key.toLowerCase().includes('token') || field.key.toLowerCase().includes('password') ? 'password' : 'text'}
													placeholder={field.defaultValue ? field.defaultValue : `Enter your ${field.label.toLowerCase()}`}
													value={inputValues[field.key] || ''}
													onChange={(e) => setInputValues(prev => ({
														...prev,
														[field.key]: e.target.value
													}))}
													className="w-full"
												/>
											</div>
										))}
									</div>
								</div>
							)}

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
										{setupCode.type === "stdio" && (
											<div className="bg-blue-50 dark:bg-blue-950/30 border border-blue-200 dark:border-blue-800 rounded-lg p-4">
												<h5 className="font-medium text-blue-900 dark:text-blue-100 mb-2">Note for stdio setup:</h5>
												<p className="text-sm text-blue-800 dark:text-blue-200">
													Make sure the command <code className="bg-blue-100 dark:bg-blue-900 px-1 rounded">{setupCode.command}</code> is available in your PATH.
												</p>
											</div>
										)}
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
										{setupCode.type === "stdio" && (
											<div className="bg-blue-50 dark:bg-blue-950/30 border border-blue-200 dark:border-blue-800 rounded-lg p-4">
												<h5 className="font-medium text-blue-900 dark:text-blue-100 mb-2">Note for stdio setup:</h5>
												<p className="text-sm text-blue-800 dark:text-blue-200">
													Make sure the command <code className="bg-blue-100 dark:bg-blue-900 px-1 rounded">{setupCode.command}</code> is available in your PATH.
												</p>
											</div>
										)}
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
						</div>
					</div>
				);

			case "tools":
				// Filter tools based on search query
				const filteredTools = tools.filter(tool => 
					tool.name.toLowerCase().includes(toolsSearch.toLowerCase()) ||
					tool.description.toLowerCase().includes(toolsSearch.toLowerCase())
				);

				return (
					<div className="h-full overflow-hidden relative">
						<div className="p-6 pb-0">
							<div className="mb-6">
								<h3 className="text-md font-semibold mb-2">Available Tools</h3>
								<p className="text-muted-foreground text-sm mb-4">
									This MCP provides {tools.length} tool{tools.length !== 1 ? 's' : ''} for integration.
								</p>
								
								{/* Search Bar */}
								<div className="relative flex justify-between items-center">
									<Search className="absolute left-3 top-[8px] text-muted-foreground w-4 h-4" />
									<Input
										placeholder="Search tools..."
										value={toolsSearch}
										onChange={(e) => setToolsSearch(e.target.value)}
										className="pl-10"
									/>
								</div>
							</div>
						</div>

						{/* Scrollable tools container */}
						<div 
							ref={toolsScrollRef}
							className="px-6 pb-6 overflow-y-auto"
							style={{ height: 'calc(100% - 160px)' }}
						>
							<div className="grid gap-4">
								{filteredTools.map((tool, index) => (
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

							{filteredTools.length === 0 && toolsSearch && (
								<div className="text-center py-8 text-muted-foreground">
									<Search className="w-12 h-12 mx-auto mb-3 opacity-50" />
									<p>No tools found matching &quot;{toolsSearch}&quot;</p>
									<Button 
										variant="outline" 
										size="sm" 
										onClick={() => setToolsSearch("")}
										className="mt-2"
									>
										Clear search
									</Button>
								</div>
							)}

							{tools.length === 0 && (
								<div className="text-center py-8 text-muted-foreground">
									<Wrench className="w-12 h-12 mx-auto mb-3 opacity-50" />
									<p>No tools available for this MCP</p>
								</div>
							)}
						</div>

						{/* Scroll glow effect */}
						{showScrollGlow && (
							<div className="absolute bottom-0 left-0 right-0 h-12 pointer-events-none bg-gradient-to-t from-background via-background/60 to-transparent" />
						)}
					</div>
				);

			default:
				return null;
		}
	};

	return (
		<div className="flex h-[500px] w-full max-h-[700px] overflow-hidden">
			<nav className="w-48 border-r pr-4 flex flex-col shrink-0">
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
				<div className="flex-1 overflow-y-auto max-h-[700px]">
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