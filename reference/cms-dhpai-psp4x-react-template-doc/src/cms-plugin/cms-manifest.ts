import pluginId from "./pluginId";

const cmsManifest = {
	pluginId,
	views: [
		{
			id: "testing-view",
			label: "PSP List",
			viewGroupId: "root",
		},
	],
	menus: [
		{
			id: "testing-view-menu",
			label: "PSP List",
			command: "hub.show.non-patient-view",
			commandArg: {
				pluginId,
				viewId: "testing-view",
				viewLabel: "PSP List",
			},
		},
	],
};

// ES module export
export const { menus, views } = cmsManifest;
