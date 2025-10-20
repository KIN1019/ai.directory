"use client";

import { useEffect, useState } from "react";
import { useSearchParams } from "next/navigation";
import { LibraryCard, LibraryData } from "./LibraryCard";

function filterLibraries(
	libraries: LibraryData[],
	searchParams: { [key: string]: string | string[] | undefined },
): LibraryData[] {
	return libraries.filter((library) => {
		// Check tech stacks filter
		if (searchParams.techStacks) {
			const selectedTechStacks =
				(typeof searchParams.techStacks === "string"
					? searchParams.techStacks.split(",")
					: searchParams.techStacks) || [];

			if (selectedTechStacks.length > 0 && library.techStacks) {
				const hasMatchingTech = selectedTechStacks.some((tech) =>
					library.techStacks?.includes(tech),
				);
				if (!hasMatchingTech) return false;
			}
		}

		// Check teams filter
		if (searchParams.teams) {
			const selectedTeams =
				(typeof searchParams.teams === "string"
					? searchParams.teams.split(",")
					: searchParams.teams) || [];

			if (selectedTeams.length > 0 && library.teams) {
				const hasMatchingTeam = selectedTeams.some((team) =>
					library.teams?.includes(team),
				);
				if (!hasMatchingTeam) return false;
			}
		}

		// Check categories filter
		if (searchParams.categories) {
			const selectedCategories =
				(typeof searchParams.categories === "string"
					? searchParams.categories.split(",")
					: searchParams.categories) || [];

			if (selectedCategories.length > 0 && library.categories) {
				const hasMatchingCategory = selectedCategories.some((category) =>
					library.categories?.includes(category),
				);
				if (!hasMatchingCategory) return false;
			}
		}

		return true;
	});
}

export default function ContextsPage() {
	const searchParams = useSearchParams();
	const [libraries, setLibraries] = useState<LibraryData[]>([]);
	const [isLoading, setIsLoading] = useState(true);
	const [error, setError] = useState<string>("");

	useEffect(() => {
		async function loadLibraries() {
			try {
				const response = await fetch("/api/contexts/libraries");
				const data = await response.json();

				if (!response.ok) {
					throw new Error(data.error || "Failed to load libraries");
				}

				setLibraries(data.libraries);
			} catch (err) {
				setError(err instanceof Error ? err.message : "Failed to load libraries");
			} finally {
				setIsLoading(false);
			}
		}

		loadLibraries();
	}, []);

	if (isLoading) {
		return (
			<div className="flex justify-center items-center h-[90vh]">
				<p className="text-muted-foreground">Loading libraries...</p>
			</div>
		);
	}

	if (error) {
		return (
			<div className="flex justify-center items-center h-[90vh]">
				<p className="text-red-500">{error}</p>
			</div>
		);
	}

	const resolvedSearchParams = Object.fromEntries(searchParams.entries());
	const filteredLibraries = filterLibraries(libraries, resolvedSearchParams);

	if (libraries.length === 0) {
		return (
			<div className="flex justify-center items-center h-[90vh]">
				<p className="text-2xl text-muted-foreground">
					No libraries found. Create library folders with _meta.yaml files in the
					/resources/contexts directory.
				</p>
			</div>
		);
	}

	if (filteredLibraries.length === 0) {
		return (
			<div className="p-8">
				<h1 className="text-2xl font-bold mb-6">Libraries</h1>
				<p className="text-muted-foreground">
					No libraries match the selected filters. Try adjusting your filters.
				</p>
			</div>
		);
	}

	return (
		<div className="p-8">
			<div className="mb-6">
				<h1 className="text-2xl font-bold mb-2">Libraries</h1>
				<p className="text-muted-foreground">
					{filteredLibraries.length} of {libraries.length} libraries available
				</p>
			</div>

			<div className="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-6">
				{filteredLibraries.map((library) => (
					<LibraryCard key={library.slug} library={library} />
				))}
			</div>
		</div>
	);
}
