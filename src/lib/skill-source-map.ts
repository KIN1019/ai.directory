/**
 * Maps raw repository folder names (used as skill `source`) to human-readable
 * display labels shown in the Skills sidebar and page headings.
 *
 * Add a new entry here whenever a new repository is added to `reference/`.
 * Any source not listed falls back to the raw folder name.
 */
const SKILL_SOURCE_MAP: Record<string, string> = {
	"cms-dhpai-aiact-test-case-generation": "AI Act Test Case Generation",
	"cms-dhpai-clap-log-doc": "CLAP Log",
	"cms-dhpai-code-review-doc": "Code Review",
	"cms-dhpai-copilot-booster-doc": "Copilot Booster",
	"cms-dhpai-copilot-doc": "Copilot",
	"cms-dhpai-copilot-playbook-doc": "Copilot Playbook",
	"cms-dhpai-copilot-template": "Copilot Template",
	"cms-dhpai-deployment-package-validation": "Deployment Package Validation",
	"cms-dhpai-hkpmi-schema-validation-doc": "HKPMI Schema Validation",
	"cms-dhpai-jest-test-generation-doc": "Jest Test Generation",
	"cms-dhpai-knowledge-doc": "Knowledge",
	"cms-dhpai-psp4x-react-template-doc": "PSP4X React Template",
	"cms-dhpai-react-chassis-data-testid-doc": "React Chassis Data TestID",
	"cms-dhpai-react-generation-doc": "React Generation",
	"cms-dhpai-searchpath-rewrite-doc": "Searchpath Rewrite",
	"cms-dhpai-sonarqube-instruction-template-doc":
		"SonarQube Instruction Template",
	"cms-dhpai-sp-evaluation-doc": "SP Evaluation",
	"cms-dhpai-swagger-openapi-springboot-generator-doc":
		"Swagger / OpenAPI SpringBoot Generator",
	"cms-dhpai-unit-test-generation-doc": "Unit Test Generation",
};

/**
 * Returns the human-readable display name for a skill source key.
 * Falls back to the raw key if no mapping is defined.
 */
export function getSkillSourceLabel(source: string): string {
	return SKILL_SOURCE_MAP[source] ?? source;
}
