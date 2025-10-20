"use client";

import { useEffect, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import {
	ExternalLink,
	Github,
	Loader2,
	ArrowLeft,
	Copy,
	Link as LinkIcon,
} from "lucide-react";

interface LibraryData {
	name: string;
	description: string;
	slug: string;
	source?: string;
	lastUpdated?: string;
	llmsTxtUrl?: string;
	techStacks?: string[];
	teams?: string[];
	categories?: string[];
}

export default function LibraryDetailPage() {
	const params = useParams();
	const router = useRouter();
	const slug = params.slug as string;

	const [library, setLibrary] = useState<LibraryData | null>(null);
	const [llmsContent, setLlmsContent] = useState<string>("");
	const [topicQuery, setTopicQuery] = useState("general");
	const [tokenSize, setTokenSize] = useState(10000);
	const [isLoading, setIsLoading] = useState(true);
	const [isLoadingContent, setIsLoadingContent] = useState(false);
	const [error, setError] = useState<string>("");
	const [copiedContent, setCopiedContent] = useState(false);
	const [copiedLink, setCopiedLink] = useState(false);

	useEffect(() => {
		async function loadLibrary() {
			try {
				const response = await fetch("/api/contexts/libraries");
				const data = await response.json();

				if (!response.ok) {
					throw new Error(data.error || "Failed to load libraries");
				}

				const foundLibrary = data.libraries.find(
					(lib: LibraryData) => lib.slug === slug,
				);

				if (!foundLibrary) {
					setError("Library not found");
					setIsLoading(false);
					return;
				}

				setLibrary(foundLibrary);

				// Fetch llms.txt content with default parameters
				if (foundLibrary.llmsTxtUrl) {
					await fetchLlmsContent(foundLibrary.llmsTxtUrl, "general", 10000);
				}
			} catch (err) {
				setError(err instanceof Error ? err.message : "Failed to load library");
			} finally {
				setIsLoading(false);
			}
		}

		loadLibrary();
	}, [slug]);

	const fetchLlmsContent = async (baseUrl: string, topic: string, tokens: number) => {
		setIsLoadingContent(true);
		setError("");

		try {
			// Build URL with topic and tokens parameters
			const urlWithParams = `${baseUrl}?topic=${encodeURIComponent(topic)}&tokens=${tokens}`;
			const llmsResponse = await fetch(
				`/api/contexts/llms-txt?url=${encodeURIComponent(urlWithParams)}`,
			);
			const llmsData = await llmsResponse.json();

			if (llmsResponse.ok) {
				setLlmsContent(llmsData.content);
			} else {
				setLlmsContent(`Failed to load content: ${llmsData.error || "Unknown error"}`);
			}
		} catch (err) {
			setError(err instanceof Error ? err.message : "Failed to load content");
		} finally {
			setIsLoadingContent(false);
		}
	};

	const handleSearch = () => {
		if (library?.llmsTxtUrl) {
			fetchLlmsContent(library.llmsTxtUrl, topicQuery, tokenSize);
		}
	};

	const formatDate = (dateString?: string) => {
		if (!dateString) return "N/A";
		try {
			return new Date(dateString).toLocaleDateString("en-US", {
				year: "numeric",
				month: "short",
				day: "numeric",
			});
		} catch {
			return dateString;
		}
	};

	const renderSource = (source?: string) => {
		if (!source) return null;

		if (source.startsWith("/")) {
			const githubUrl = `https://github.com${source}`;
			return (
				<a
					href={githubUrl}
					target="_blank"
					rel="noopener noreferrer"
					className="flex items-center gap-2 text-teal-600 hover:text-teal-800 dark:text-teal-400 dark:hover:text-teal-300"
				>
					<Github className="w-4 h-4" />
					<span>{source}</span>
					<ExternalLink className="w-3 h-3" />
				</a>
			);
		}

		if (source.startsWith("http://") || source.startsWith("https://")) {
			return (
				<a
					href={source}
					target="_blank"
					rel="noopener noreferrer"
					className="flex items-center gap-2 text-teal-600 hover:text-teal-800 dark:text-teal-400 dark:hover:text-teal-300"
				>
					<ExternalLink className="w-4 h-4" />
					<span>{source.replace(/^https?:\/\//, "")}</span>
				</a>
			);
		}

		return <span>{source}</span>;
	};


	const handleCopy = async () => {
		await navigator.clipboard.writeText(llmsContent);
		setCopiedContent(true);
		setTimeout(() => setCopiedContent(false), 2000);
	};

	const handleCopyLink = async () => {
		if (library?.llmsTxtUrl) {
			const urlWithParams = `${library.llmsTxtUrl}?topic=${encodeURIComponent(topicQuery)}&tokens=${tokenSize}`;
			await navigator.clipboard.writeText(urlWithParams);
			setCopiedLink(true);
			setTimeout(() => setCopiedLink(false), 2000);
		}
	};

	if (isLoading) {
		return (
			<div className="flex justify-center items-center h-[90vh]">
				<Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
			</div>
		);
	}

	if (error || !library) {
		return (
			<div className="flex flex-col justify-center items-center h-[90vh] gap-4">
				<p className="text-red-500">{error || "Library not found"}</p>
				<Button onClick={() => router.push("/contexts")}>Back to Libraries</Button>
			</div>
		);
	}

	return (
		<div className="container mx-auto px-4 py-8 max-w-6xl">
			{/* Back Button */}
			<Button
				variant="ghost"
				size="sm"
				className="mb-6"
				onClick={() => router.push("/contexts")}
			>
				<ArrowLeft className="w-4 h-4 mr-2" />
				Back to Libraries
			</Button>

			{/* Header */}
			<div className="border rounded-lg p-6 mb-8">
				<div className="mb-4">
					<h1 className="text-3xl font-bold mb-2">{library.name}</h1>
					{library.source && (
						<div className="mb-3">{renderSource(library.source)}</div>
					)}
					<p className="text-muted-foreground">{library.description}</p>
				</div>

				<div className="flex items-center gap-6 text-sm text-muted-foreground">
					{library.llmsTxtUrl && (
						<a
							href={library.llmsTxtUrl}
							target="_blank"
							rel="noopener noreferrer"
							className="flex items-center gap-1 text-teal-600 hover:text-teal-800 dark:text-teal-400 dark:hover:text-teal-300"
						>
							View llms.txt
							<ExternalLink className="w-3 h-3" />
						</a>
					)}
				</div>
			</div>

			{/* Search Section */}
			<div className="mb-8">
				<h2 className="text-sm font-medium text-muted-foreground mb-4">
					SEARCH DOCUMENTATION
				</h2>
				<div className="border rounded-lg p-6 space-y-6">
					{/* Topic Search */}
					<div>
						<label className="text-sm font-medium mb-2 block">
							Topic (e.g., component, API, authentication)
						</label>
						<div className="flex gap-4">
							<Input
								placeholder="e.g. button, authentication, routing..."
								className="flex-1"
								value={topicQuery}
								onChange={(e) => setTopicQuery(e.target.value)}
								onKeyDown={(e) => {
									if (e.key === "Enter") {
										handleSearch();
									}
								}}
							/>
							<Button
								className="bg-teal-800 hover:bg-teal-700 text-white"
								onClick={handleSearch}
								disabled={isLoadingContent}
							>
								{isLoadingContent ? (
									<>
										<Loader2 className="w-4 h-4 mr-2 animate-spin" />
										Loading...
									</>
								) : (
									"Search"
								)}
							</Button>
						</div>
					</div>

					{/* Token Size Slider */}
					<div>
						<div className="flex justify-between items-center mb-2">
							<label className="text-sm font-medium">
								Token Budget (Response Size)
							</label>
							<span className="text-sm text-muted-foreground">
								{tokenSize.toLocaleString()} tokens
							</span>
						</div>
						<input
							type="range"
							min="1000"
							max="30000"
							step="1000"
							value={tokenSize}
							onChange={(e) => setTokenSize(Number(e.target.value))}
							className="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer dark:bg-gray-700"
						/>
						<div className="flex justify-between text-xs text-muted-foreground mt-1">
							<span>1k</span>
							<span>10k</span>
							<span>20k</span>
							<span>30k</span>
						</div>
					</div>

					<p className="text-xs text-muted-foreground">
						💡 Adjust topic and token size, then click <strong>Search</strong> to
						fetch filtered documentation from the DHP AI Code Context API.
					</p>
				</div>
			</div>

			{/* Content Section */}
			<div>
				<h2 className="text-sm font-medium text-muted-foreground mb-4">
					DOCUMENTATION CONTENT
				</h2>
				<div className="border rounded-lg">
					<div className="border-b p-4 flex items-center justify-between">
						<span className="text-sm font-medium">llms.txt Documentation</span>
						<div className="flex gap-2">
							<Button
								variant="outline"
								size="sm"
								onClick={handleCopy}
								disabled={!llmsContent}
								title="Copy documentation content"
							>
								<Copy className="w-4 h-4 mr-2" />
								{copiedContent ? "Copied!" : "Copy Text"}
							</Button>
							<Button 
								variant="outline" 
								size="sm" 
								onClick={handleCopyLink}
								disabled={!library?.llmsTxtUrl}
								title="Copy llms.txt URL with current parameters"
							>
								<LinkIcon className="w-4 h-4 mr-2" />
								{copiedLink ? "Copied!" : "Copy Link"}
							</Button>
						</div>
					</div>

					<div className="p-6">
						{isLoadingContent && (
							<div className="flex items-center justify-center py-8">
								<Loader2 className="h-6 w-6 animate-spin text-muted-foreground" />
							</div>
						)}

						{!isLoadingContent && llmsContent && (
							<div className="bg-muted rounded-lg p-4 max-h-[600px] overflow-auto">
								<pre className="text-sm whitespace-pre-wrap font-mono">
									{llmsContent}
								</pre>
							</div>
						)}

						{!isLoadingContent && !llmsContent && (
							<div className="text-center text-muted-foreground py-8">
								No documentation content available for this library.
							</div>
						)}
					</div>
				</div>
			</div>
		</div>
	);
}
