import { pluginId } from "./cms-plugin/pluginId";

// for ECP/k8s, being replaced by script in Dockerfile
window[`cms-${pluginId}`] = {
	mySvcUrl: "$PLACEHOLDER_MY_SVC_URL",
};
