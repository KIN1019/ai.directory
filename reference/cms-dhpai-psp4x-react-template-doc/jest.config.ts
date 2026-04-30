// jest.config.ts
import type { Config } from "jest";

const config: Config = {
	testEnvironment: "jest-environment-jsdom",
	setupFilesAfterEnv: ["<rootDir>/src/setupTests.ts"],
	transform: {
		"^.+\\.(t|j)sx?$": [
			"@swc/jest",
			{
				jsc: {
					parser: {
						tsx: true,
						syntax: "typescript",
					},
					transform: {
						react: {
							runtime: "automatic",
						},
					},
				},
				isModule: "unknown",
			},
		],
	},
	collectCoverageFrom: ["src/**/*.{js,jsx,ts,tsx}"],
};

export default config;
