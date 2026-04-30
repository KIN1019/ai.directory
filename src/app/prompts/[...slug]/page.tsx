import { redirect } from "next/navigation";
import { RulesCardWithDrawer } from "../RulesCard";
import {
	getRuleSectionTitle,
	getRulesBySection,
	getRulesBySectionAndTag,
	getRulesByTag,
	getTagName,
	isRuleSection,
	type RuleDocument,
	type RuleSection,
} from "../rules-data";

type RulesPageState = {
	title: string;
	rules: RuleDocument[];
	selectedRuleSlug?: string;
	getRuleHref: (rule: RuleDocument) => string;
};

type RulesPageSearchParams = {
	[key: string]: string | string[] | undefined;
};

function getSelectedSectionTags(
	searchParams: RulesPageSearchParams,
	section: RuleSection,
) {
	const rawValue = searchParams[section];
	let values: string[] = [];

	if (Array.isArray(rawValue)) {
		values = rawValue.flatMap((value) => value.split(","));
	} else if (typeof rawValue === "string") {
		values = rawValue.split(",");
	}

	return [...new Set(values.filter(Boolean))];
}

function buildSearchSuffix(searchParams: RulesPageSearchParams) {
	const params = new URLSearchParams();

	Object.entries(searchParams).forEach(([key, value]) => {
		if (Array.isArray(value)) {
			value.forEach((entry) => {
				if (entry) {
					params.append(key, entry);
				}
			});
			return;
		}

		if (typeof value === "string" && value.length > 0) {
			params.set(key, value);
		}
	});

	const queryString = params.toString();
	return queryString ? `?${queryString}` : "";
}

function filterRulesByTags(rules: RuleDocument[], tags: string[]) {
	if (tags.length === 0) {
		return rules;
	}

	return rules.filter((rule) => tags.every((tag) => rule.tags.includes(tag)));
}

async function getSectionPageState(
	section: RuleSection,
	segments: string[],
): Promise<RulesPageState> {
	const sectionTitle = getRuleSectionTitle(section);
	const sectionRules = await getRulesBySection(section);

	if (segments.length === 1) {
		return {
			title: `${sectionTitle} Rules`,
			rules: sectionRules,
			getRuleHref: (rule) => `/prompts/${section}/${rule.slug}`,
		};
	}

	const secondSegment = segments[1];
	const isTagSegment = sectionRules.some((rule) =>
		rule.tags.includes(secondSegment),
	);

	if (!isTagSegment) {
		return {
			title: `${sectionTitle} Rules`,
			rules: sectionRules,
			selectedRuleSlug: secondSegment,
			getRuleHref: (rule) => `/prompts/${section}/${rule.slug}`,
		};
	}

	const tagName = await getTagName(secondSegment);
	const filteredRules = await getRulesBySectionAndTag(section, secondSegment);

	return {
		title: `${sectionTitle} / ${tagName}`,
		rules: filteredRules,
		selectedRuleSlug: segments[2],
		getRuleHref: (rule) => `/prompts/${section}/${secondSegment}/${rule.slug}`,
	};
}

async function getTagPageState(segments: string[]): Promise<RulesPageState> {
	const tag = segments[0];
	const tagName = await getTagName(tag);
	const rules = await getRulesByTag(tag);

	return {
		title: `${tagName} Rules`,
		rules,
		selectedRuleSlug: segments[1],
		getRuleHref: (rule) => `/prompts/${tag}/${rule.slug}`,
	};
}

export default async function RulesPage({
	params,
	searchParams,
}: {
	params: Promise<{ slug: string[] }>;
	searchParams: Promise<RulesPageSearchParams>;
}) {
	const { slug } = await params;
	const resolvedSearchParams = await searchParams;

	if (slug.length === 0) {
		redirect("/prompts/instructions");
	}

	let pageState = isRuleSection(slug[0])
		? await getSectionPageState(slug[0], slug)
		: await getTagPageState(slug);
	const searchSuffix = buildSearchSuffix(resolvedSearchParams);

	if (isRuleSection(slug[0])) {
		const selectedTags = getSelectedSectionTags(resolvedSearchParams, slug[0]);

		if (selectedTags.length > 0) {
			const selectedTagNames = await Promise.all(
				selectedTags.map((tag) => getTagName(tag)),
			);

			pageState = {
				...pageState,
				title: `${getRuleSectionTitle(slug[0])} / ${selectedTagNames.join(", ")}`,
				rules: filterRulesByTags(pageState.rules, selectedTags),
			};
		}
	}

	const baseGetRuleHref = pageState.getRuleHref;
	pageState = {
		...pageState,
		getRuleHref: (rule) => `${baseGetRuleHref(rule)}${searchSuffix}`,
	};

	return (
		<div className="p-8 pb-32 w-full">
			<h1 className="text-2xl font-bold mb-6">{pageState.title}</h1>
			{pageState.rules.length > 0 ? (
				<div className="grid grid-cols-1 xl:grid-cols-2 2xl:grid-cols-3 gap-3">
					{pageState.rules.map((rule) => (
						<RulesCardWithDrawer
							key={rule.slug}
							title={rule.title}
							description={rule.description}
							content={rule.content}
							tags={rule.tags}
							open={pageState.selectedRuleSlug === rule.slug}
							href={pageState.getRuleHref(rule)}
						/>
					))}
				</div>
			) : (
				<p className="text-muted-foreground">
					No rules found for: {slug.join(" / ")}
				</p>
			)}
		</div>
	);
}
