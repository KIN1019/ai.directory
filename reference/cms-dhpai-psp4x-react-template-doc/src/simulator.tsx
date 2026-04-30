import {
	HubSimulator,
	PluginDescriptor,
	afterLoginProcess,
	configureHub,
	pluginLoader,
} from "@cmschassis/cms-dev-kit";
import { BasicTheme } from "@cmschassis/react-ui";
import { ThemeProvider } from "@mui/material";
import React from "react";
import ReactDOM from "react-dom/client";
import pluginManifest from "./cms-plugin/plugin-manifest.module";
import "./style.css";

import { LicenseInfo } from "@mui/x-license";

LicenseInfo.setLicenseKey(
	"1ba90f6dd6b2a4d887c629922c3f7a18Tz05NjA4MyxFPTE3NTUxODM3NzUwMDAsUz1wcm8sTE09cGVycGV0dWFsLFBWPWluaXRpYWwsS1Y9Mg==",
);

/**
 * This is the entry point of the simulator.
 */
const hubSvcUrls = {
	userProfile:
		"https://user-profile-svc-cmschassis-dev.tstcld61.server.ha.org.hk",
	patient: "https://patient-svc-cmschassis-dev.tstcld61.server.ha.org.hk",
};
const authInfo = {
	accessToken: "test-access-token",
	permissions: ["test-permission"],
};

/**
 * Configure what other plugins to load together
 */
const otherPlugins: PluginDescriptor[] = [
	{
		id: "PatientPanel",
		scriptUrl:
			"https://cms-patient-panel-app-cmschassis-dev.tstcld61.server.ha.org.hk/remoteEntry.js",
	},
];

/**
 * Configure the hub service urls and auth info.
 */
configureHub(hubSvcUrls, authInfo);
afterLoginProcess();

/**
 * Render the simulator.
 */
const root = ReactDOM.createRoot(
	document.getElementById("root") as HTMLElement,
);
root.render(
	<React.StrictMode>
		<ThemeProvider theme={BasicTheme}>
			<HubSimulator
				pluginLoader={pluginLoader}
				myPlugin={pluginManifest}
				otherPlugins={otherPlugins}
			/>
		</ThemeProvider>
	</React.StrictMode>,
);
