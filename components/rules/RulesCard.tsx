"use client";

import {
	Card,
	CardContent,
	CardDescription,
	CardFooter,
	CardHeader,
	CardTitle,
} from "@/components/ui/card";
import {
	Drawer,
	DrawerClose,
	DrawerContent,
	DrawerDescription,
	DrawerFooter,
	DrawerHeader,
	DrawerTitle,
	DrawerTrigger,
} from "@/components/ui/drawer";
import { Button } from "@/components/ui/button";
import { toast } from "sonner";
import { useState, useRef } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { usePathname } from "next/navigation";

interface RulesCardProps {
	title: string;
	description: string;
	content: string;
	tags: string[];
	open: boolean;
	href: string;
}

function RulesCardWithDrawer(props: RulesCardProps) {
	const router = useRouter();
	const pathname = usePathname();
	const [open, setOpen] = useState(props.open);
	const pendingRoute = useRef<string | null>(null);

	const close = () => {
		setOpen(false);
		pendingRoute.current = pathname.split("/").slice(0, 3).join("/");
	};

	const handleOpenChange = (isOpen: boolean) => {
		setOpen(isOpen);
		if (!isOpen && pendingRoute.current) {
			router.push(pendingRoute.current);
			pendingRoute.current = null;
		}
	};

	return (
		<Drawer open={open} onClose={close} onAnimationEnd={handleOpenChange}>
			<Link href={props.href}>
				<div className="h-full w-full group relative">
					<DrawerTrigger className="absolute h-full w-full z-1" />
					<RulesCard {...props} />
				</div>
			</Link>
			<RulesDrawer {...props} />
		</Drawer>
	);
}

function RulesCard(props: RulesCardProps) {
	return (
		<Card className="h-fit">
			<CardHeader>
				<CardTitle>{props.title}</CardTitle>
				<CardDescription className="h-10 overflow-hidden">{props.description}</CardDescription>
			</CardHeader>
			<CardContent className="h-fit relative">
				<div className="font-mono bg-secondary text-xs whitespace-pre-wrap px-3 py-2 h-96 overflow-auto rounded-xs">
					<p className="line-clamp-[23] opacity-50 group-hover:opacity-100">
						{props.content.trim()}
					</p>
				</div>
			</CardContent>
			<CardFooter>
				<RulesCardTags tags={props.tags} />
			</CardFooter>
		</Card>
	);
}

interface RulesCardTagsProps {
	tags: string[];
}

function RulesCardTags(props: RulesCardTagsProps) {
	return <p className="text-xs font-mono ">{props.tags.join(", ")}</p>;
}

interface RulesDrawerProps {
	title: string;
	description: string;
	content: string;
	tags: string[];
}

function RulesDrawer(props: RulesDrawerProps) {
	const [isCopied, setIsCopied] = useState(false);

	const handleCopy = async () => {
		try {
			await navigator.clipboard.writeText(props.content.trim());
			setIsCopied(true);
			toast("Rule has been copied!");
			setTimeout(() => setIsCopied(false), 2000);
		} catch (err) {
			console.error("Failed to copy text:", err);
		}
	};

	return (
		<DrawerContent>
			<DrawerHeader>
				<DrawerTitle>{props.title}</DrawerTitle>
				<DrawerDescription>{props.description}</DrawerDescription>
				<Button onClick={handleCopy}>{isCopied ? "Copied" : "Copy"}</Button>
			</DrawerHeader>
			<hr />
			<DrawerFooter>
				<div className="font-mono bg-secondary text-xs px-3 py-2 h-[550px] overflow-auto whitespace-pre-wrap rounded-sm">
					<p className="overflow-y-scroll">{props.content.trim()}</p>
				</div>
			</DrawerFooter>
		</DrawerContent>
	);
}

export { RulesCardWithDrawer };
