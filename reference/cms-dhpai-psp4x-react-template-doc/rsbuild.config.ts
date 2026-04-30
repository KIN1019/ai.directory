// rsbuild.config.ts
import { pluginModuleFederation } from "@module-federation/rsbuild-plugin";
import { defineConfig, loadEnv } from "@rsbuild/core";
import { pluginEslint } from "@rsbuild/plugin-eslint";
import { pluginReact } from "@rsbuild/plugin-react";
import fs from "node:fs";
import os from "os";

import pluginId from "./src/cms-plugin/pluginId"; // A unique plugin identifier

const { publicVars, rawPublicVars } = loadEnv({ prefixes: ["REACT_APP_"] });

const isDev = process.env.NODE_ENV === "development";

export default defineConfig({
	plugins: [
		pluginReact(),
		pluginEslint({
			eslintPluginOptions: {
				configType: "flat",
			},
		}),
		pluginModuleFederation({
			// This is the pluginId
			name: pluginId,

			filename: "remoteEntry.js",
			exposes: {
				Manifest: "./src/cms-plugin/plugin-manifest.module.ts", // RSBUILD: added .ts extension
			},
			shared: {
				"emotion/react": {
					singleton: true,
				},
				"emotion/styled": {
					singleton: true,
				},
			},
		}),
	],
	html: {
		template: "./public/index.html",
	},
	output: {
		distPath: {
			root: "build",
		},
	},
	source: {
		define: { ...publicVars, "process.env": JSON.stringify(rawPublicVars) },
		entry: {
			// Standalone App (for local test in future)
			// RSBUILD: changed entry to index instead of 'main'
			index: {
				filename: "[name].[contenthash].js",
				import: isDev ? "./src/cms-dev-kit.js" : "./src/index.js",
				publicPath: "/",
				dependOn: pluginId,
			},
			// SPA plugin
			[pluginId]: {
				filename: "remoteEntry.js",
				import: "./src/remoteEntry.js",
				publicPath: "auto",
				html: false, // RSBUILD: disable html for SPA plugin
			},
		},
	},
	tools: {
		rspack: {
			// rsbuild doesn't use rspack's devServer but instead implement its own version, therefore devServer doesn't work
			// https://rsbuild.dev/guide/basic/server#rspack-dev-server
			devServer: {},
			optimization: {
				chunkIds: "named",
				moduleIds: "deterministic",
			},
		},
	},
	server: {
		port: process.env.PORT ? Number(process.env.PORT) : 3000,
		// mimic devServer configs
		...(isDev
			? {
					headers: {
						"Access-Control-Allow-Origin": "*",
						"Access-Control-Allow-Methods": "*",
						"Access-Control-Allow-Headers": "*",
					},
					publicDir: [
						{
							name: "public",
						},
						{
							name: "app-config-local",
						},
					],
					https:
						process.env.SSL_CRT_FILE && process.env.SSL_KEY_FILE
							? {
									// ca: process.env.SSL_CA_CRT_FILE,
									cert: fs.readFileSync(process.env.SSL_CRT_FILE),
									key: fs.readFileSync(process.env.SSL_KEY_FILE),
								}
							: undefined,
					proxy: {
						"/api": {
							target:
								"https://cms-psp-api-svc-cmschassis-dev.tstcld61.server.ha.org.hk",
							changeOrigin: true,
							secure: false,
							pathRewrite: { "^/api": "" },
						},
					},
				}
			: {}),
	},
	dev: {
		// set as '/' to be relative
		assetPrefix: "/",
		setupMiddlewares: os.hostname()
			? [
					// devServer.allowedHost
					(middlewares) => {
						middlewares.unshift((req, res, next) => {
							const isHttps = req.headers[":scheme"] === "https";
							if (isHttps) return next();

							const hostname = req.headers.host?.split(":")[0] ?? "";
							const osHostname = os.hostname().endsWith(".ha.org.hk")
								? os.hostname() // Mac return full hostname
								: `${os.hostname()}.corp.ha.org.hk`; // Windows return short hostname

							// If hostname is not localhost or osHostname, return 401
							if (!["localhost", osHostname].includes(hostname)) {
								res.statusCode = 401;
							}
							next();
						});
					},
				]
			: undefined,
	},
});
