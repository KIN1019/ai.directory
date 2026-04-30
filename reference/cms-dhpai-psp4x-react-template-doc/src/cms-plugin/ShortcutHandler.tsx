import { Shortcut } from "@cmschassis/cmsaf-js";
import { useEffect } from "react";
import cms from "./cms-api-provider";

type ShortcutHandlerProps = {
	children?: React.ReactNode;
};

export const ShortcutHandler = ({ children }: ShortcutHandlerProps) => {
	const session = cms.api.session?.get().environment;

	useEffect(() => {
		//TODO: some flag to only enable on cms4X
		if (!session || !session?.shell || !session?.shell.startsWith("M")) {
			Shortcut.enable();
		}
	}, [session, session?.shell]);

	return <>{children}</>;
};
