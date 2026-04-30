import createCache from "@emotion/cache";
import { CacheProvider } from "@emotion/react";
import React from "react";
import ReactDOM from "react-dom/client";
import { cleanUp } from "./clean-up";
import pluginId from "./pluginId";
import { ShortcutHandler } from "./ShortcutHandler";
import { ThemeWrapper } from "./ThemeWrapper";
/**
 * initialize React framework to show the component
 * @param element
 * @param component
 */
export function renderReactComponent<T extends object>(
	element: HTMLElement,
	component: React.ComponentType<T>,
	props?: T, // add props argument
) {
	// MUI styles are generated here, it'd be unloaded when the component is unmounted
	const emotionRoot = document.createElement("style");
	element.appendChild(emotionRoot);
	const cache = createCache({
		key: pluginId.toLowerCase(), // "lower case" alphabetical characters only
		container: emotionRoot,
		/**
		 * Disable speedy for deteched element
		 * https://github.com/emotion-js/emotion/discussions/2903#discussioncomment-3914196
		 */
		speedy: false,
	});

	// Append React
	const reactRoot = document.createElement("div");
	reactRoot.style.cssText = "width:100%;height:100%;overflow-y:auto";
	element.appendChild(reactRoot);
	const root = ReactDOM.createRoot(reactRoot);

	root.render(
		<React.StrictMode>
			<ShortcutHandler>
				<CacheProvider value={cache}>
					<ThemeWrapper>{React.createElement(component, props)}</ThemeWrapper>
				</CacheProvider>
			</ShortcutHandler>
		</React.StrictMode>,
	);

	cleanUp(reactRoot, root, emotionRoot, cache, element);
}
