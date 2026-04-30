import { manifest } from "@cmschassis/cms-js";
import { PspList } from "../modules/psp-list";
import cms from "./cms-api-provider";
import { menus, views } from "./cms-manifest";
import pluginId from "./pluginId";
import { renderReactComponent } from "./view-handler";

const pluginManifest: manifest.CmsPlugin = {
	id: pluginId,
	declare: (context) => {
		// declare views
		context.contributeViews(views);

		// declare menu
		context.contributeMenus(menus);
	},
	activate: (context) => {
		// Keep the context for future usage
		cms.api = context;

		cms.api.ui.onWillDisplayView(
			views[0].id,
			({ element }) => {
				renderReactComponent(element, PspList, {});
				return Promise.resolve();
			},
			pluginId,
		);
	},
};

export default pluginManifest;
