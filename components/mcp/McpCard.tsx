"use client";

import Image from "next/image";
import {
	Card,
	CardContent,
	CardDescription,
	CardFooter,
	CardHeader,
	CardTitle,
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge"
import { useState } from "react";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"
import { Separator } from "@radix-ui/react-dropdown-menu";
import { McpDialogMain } from "./McpDialogContent";
import { useRouter, useSearchParams } from "next/navigation";

type Tool = {
	name: string;
	description: string;
	[key: string]: unknown;
};

type McpCardProps = {
	name: string;
	description: string;
	logo: string;
	tools: Tool[];
	href: string;
	setupCode:
		| { type: "sse", url: string }
		| { type: "stdio", command: string, args: string[], env: { [key: string]: string } };
	fileName?: string;
	open?: boolean;
};

function McpCard(props: McpCardProps) {
	const [isHovered, setIsHovered] = useState(false);

	return (
		<Card onMouseEnter={() => setIsHovered(true)} onMouseLeave={() => setIsHovered(false)}>
			<CardHeader className="flex flex-row justify-start gap-4 items-center">
				<Image 
					src={props.logo} 
					alt={props.name} 
					width={40}
					height={40}
					className="rounded object-cover" 
				/>
				<CardTitle className="text-sm">{props.name}</CardTitle>
			</CardHeader>
			<CardContent className="flex flex-col gap-y-4">
				<p className="text-xs h-8 overflow-hidden text-ellipsis">{props.description}</p>
				<Badge variant={isHovered ? "default" : "outline"}>{props.tools.length} tools</Badge>
			</CardContent>
		</Card>
	)
}

function McpCardWithDialog(props: McpCardProps) {
	const router = useRouter();
	const searchParams = useSearchParams();
	const mcpSlug = props.fileName?.replace('.yaml', '') || props.name.toLowerCase().replace(/\s+/g, '-');

	const handleDialogChange = (open: boolean) => {
		const params = new URLSearchParams(searchParams);
		
		if (open) {
			params.set('dialog', mcpSlug);
		} else {
			params.delete('dialog');
		}
		
		const queryString = params.toString();
		router.push(`/mcp${queryString ? '?' + queryString : ''}`);
	};

	return (
		<Dialog open={props.open} onOpenChange={handleDialogChange}>
			<DialogTrigger asChild>
				<div className="cursor-pointer">
					<McpCard {...props} />
				</div>
			</DialogTrigger>
			<DialogContent className="sm:max-w-[800px] min-h-[400px] rounded-sm">
				<DialogHeader>
					<DialogTitle>{props.name}</DialogTitle>
					<DialogDescription>
						{props.description}
					</DialogDescription>
				</DialogHeader>
				<Separator />
				<McpDialogMain {...props} />
			</DialogContent>
		</Dialog>
	)
}

export { McpCard, McpCardWithDialog }
