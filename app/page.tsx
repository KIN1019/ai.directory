import { HomeBento } from "@/components/home/BentoGrid";
import Image from "next/image";
import Link from "next/link";
import { McpMarquee } from "@/components/home/McpMarquee";

export default function Home() {
	return (
		<div className="pt-16 w-screen">
			<main className="row-start-2 items-center sm:items-start pb-32">
				<div className="w-fit mx-auto">
					<div className="flex gap-4 my-6">
						<div className="font-mono text-4xl">dhpai.home</div>
					</div>
					<HomeBento />
				</div>
				<McpMarquee />
				<div className="mx-auto my-12 w-fit flex gap-4 items-center flex-col sm:flex-row">
					<Link
						className="rounded-full border border-solid border-transparent transition-colors flex items-center justify-center bg-foreground text-background gap-2 hover:bg-[#383838] dark:hover:bg-[#ccc] font-medium text-sm sm:text-base h-10 sm:h-12 px-4 sm:px-5 w-full sm:w-auto md:w-[158px]"
						href="/"
						target="_blank"
						rel="noopener noreferrer"
					>
						Kickstart
					</Link>
					<a
						className="rounded-full border border-solid border-black/[.08] dark:border-white/[.145] transition-colors flex items-center justify-center hover:bg-[#f2f2f2] dark:hover:bg-[#1a1a1a] hover:border-transparent font-medium text-sm sm:text-base h-10 sm:h-12 px-4 sm:px-5 w-full sm:w-auto md:w-[158px]"
						href="https://hagithub.home"
						target="_blank"
						rel="noopener noreferrer"
					>
						Contribute
					</a>
				</div>
			</main>
		</div>
	);
}
