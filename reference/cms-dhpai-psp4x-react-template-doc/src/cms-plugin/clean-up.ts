import { EmotionCache } from "@emotion/react";
import ReactDOM from "react-dom/client";

const observerOptions = {
	childList: true,
	subtree: true,
};

export function cleanUp(
	reactRootEl: HTMLDivElement,
	reactRoot: ReactDOM.Root,
	emotionRootEl: HTMLStyleElement,
	cache: EmotionCache,
	containerEl: HTMLElement,
) {
	function cleanUpOnDomRemoval(
		records: MutationRecord[],
		observer: MutationObserver,
	) {
		for (const record of records) {
			record.removedNodes.forEach((node) => {
				if (node === reactRootEl) {
					reactRoot.unmount();
				} else if (node === emotionRootEl) {
					cache.sheet.flush();
				}
			});
			if (record.target.childNodes.length === 0) {
				observer.disconnect();
			}
		}
	}

	const observer = new MutationObserver(cleanUpOnDomRemoval);
	observer.observe(containerEl, observerOptions);
}
