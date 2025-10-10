import { FileTextIcon, InputIcon } from "@radix-ui/react-icons";
import { Share2Icon, Code } from "lucide-react";
import { cn } from "@/lib/utils";
import AnimatedBeamMultipleOutputDemo from "@/components/magicui/example/animated-beam-multiple-outputs";
import AnimatedListDemo from "@/components/magicui/example/animated-list-demo";
import { BentoCard, BentoGrid } from "@/components/magicui/bento-grid";
import { Marquee } from "@/components/magicui/marquee";
import CodeComparisonDemo from "../magicui/example/code-comparison-demo";
import Link from "next/link";
import matter from "gray-matter";
import path from "path";
import fs from "fs";

type File = {
	href: string;
	name: string;
	body: string;
};

async function getRulesFiles(): Promise<File[]> {
	try {
		const rulesDirectory = path.join(process.cwd(), "resources", "rules");
		const fileNames = fs
			.readdirSync(rulesDirectory)
			.filter((file) => file.endsWith(".md"));

		const rules = fileNames.map((fileName) => {
			const filePath = path.join(rulesDirectory, fileName);
			const fileContent = fs.readFileSync(filePath, "utf8");
			const { data } = matter(fileContent);
			const slug = fileName.replace(".md", "");

			return {
				href: `/prompts/${data.tags && data.tags.length > 0 ? data.tags[0] : "react"}/${slug}`,
				name: data.title || fileName.replace(".md", ""),
				body: data.description || "No description available",
				tags: data.tags || [],
			};
		});

		// Shuffle the array to get random order
		return rules.sort(() => Math.random() - 0.5);
	} catch (error) {
		console.error("Error reading rules:", error);
		// Fallback to static content if there's an error
		return [
			{
				href: "/rules/react",
				name: "HA Frontend Developer",
				body: "You are a Senior Front-End Developer and an Expert in ReactJS, JavaScript, TypeScript, HTML, CSS and modern UI/UX frameworks including MUI 5.",
			},
		];
	}
}

async function DynamicRulesMarquee() {
	const files = await getRulesFiles();

	return (
		<Marquee
			pauseOnHover
			className="absolute top-10 [--duration:20s] [mask-image:linear-gradient(to_top,transparent_40%,#000_100%)] "
		>
			{files.map((f, idx) => (
				<Link key={idx} href={f.href} className="block">
					<figure
						className={cn(
							"relative w-32 cursor-pointer overflow-hidden rounded-xl border p-4",
							"border-gray-950/[.1] bg-gray-950/[.01] hover:bg-gray-950/[.05]",
							"dark:border-gray-50/[.1] dark:bg-gray-50/[.10] dark:hover:bg-gray-50/[.15]",
							"transform-gpu blur-[1px] transition-all duration-300 ease-out hover:blur-none",
						)}
					>
						<div className="flex flex-row items-center gap-2">
							<div className="flex flex-col">
								<figcaption className="text-sm font-medium dark:text-white">
									{f.name}
								</figcaption>
							</div>
						</div>
						<blockquote className="mt-2 text-xs">{f.body}</blockquote>
					</figure>
				</Link>
			))}
		</Marquee>
	);
}

const features = [
	{
		Icon: FileTextIcon,
		name: "Rules & Instructions",
		description: "Find rules that fit HA's use cases.",
		href: "/prompts",
		cta: "Learn more",
		className: "col-span-3 lg:col-span-1",
		background: <DynamicRulesMarquee />,
	},
	{
		Icon: Code,
		name: "IDE Integration",
		description:
			"Integrate our AI tools in IDEs to nitro boost your efficiency.",
		href: "/docs/github-copilot/setup",
		cta: "Learn more",
		className: "col-span-3 lg:col-span-2",
		background: (
			<CodeComparisonDemo className="absolute right-2 top-4 h-[300px] w-full scale-75 border-none transition-all duration-300 ease-out [mask-image:linear-gradient(to_top,transparent_10%,#000_100%)] group-hover:scale-90" />
		),
	},
	{
		Icon: Share2Icon,
		name: "MCP Integrations",
		description: "Provides MCP integration for internal libraries & services.",
		href: "/mcp",
		cta: "Learn more",
		className: "col-span-3 lg:col-span-2",
		background: (
			<AnimatedBeamMultipleOutputDemo className="absolute right-2 top-4 h-[300px] border-none transition-all duration-300 ease-out [mask-image:linear-gradient(to_top,transparent_10%,#000_100%)] group-hover:scale-105" />
		),
	},
	{
		Icon: InputIcon,
		name: "AI Chat and Search",
		description: "Chat with AI and search for informations.",
		className: "col-span-3 lg:col-span-1",
		href: "https://hagithub.home/pages/CMS/cms-dhp-migration-doc/",
		cta: "Learn more",
		background: (
			<AnimatedListDemo className="absolute right-2 top-4 h-[300px] w-full scale-75 border-none transition-all duration-300 ease-out [mask-image:linear-gradient(to_top,transparent_10%,#000_100%)] group-hover:scale-90" />
		),
	},
];

function HomeBento() {
	return (
		<>
			<BentoGrid>
				{features.map((feature, idx) => (
					<BentoCard key={idx} {...feature} />
				))}
			</BentoGrid>
		</>
	);
}
export { HomeBento };
