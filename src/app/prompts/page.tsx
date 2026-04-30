import { redirect } from "next/navigation";

export default async function RulesHome() {
	redirect("/prompts/instructions");
}
