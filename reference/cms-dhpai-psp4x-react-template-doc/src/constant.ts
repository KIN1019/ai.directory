import { pluginId } from "./cms-plugin/pluginId";

declare global {
	interface Window {
		[index: string]: {
			mySvcUrl: string;
		};
	}
}

// 1. for local DEV only, read REACT_APP_MY_SVC_URL from .env.xxxxx
// 2. for ECP/k8s, read from global var which is provided at remoteEntry.js
export const mySvcUrl: string | undefined =
	process.env.REACT_APP_MY_SVC_URL || window[`cms-${pluginId}`]?.mySvcUrl;
