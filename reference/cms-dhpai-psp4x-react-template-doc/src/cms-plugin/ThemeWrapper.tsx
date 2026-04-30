import { getBasicTheme } from "@cmschassis/react-ui";
import { ThemeProvider } from "@mui/material";
import { useEffect, useState } from "react";
import cms from "./cms-api-provider";

type ThemeWrapperProps = {
	children?: React.ReactNode;
};

export const ThemeWrapper = ({ children }: ThemeWrapperProps) => {
	const [appearancePreference, setAppearancePreference] = useState(
		cms.api.preference?.get().appearance,
	);

	useEffect(() => {
		const subAppearance = cms.api.preference?.subscribe(
			(preference) => preference.appearance,
			setAppearancePreference,
		);
		return () => {
			subAppearance?.dispose();
		};
	}, []);

	const fontSize = appearancePreference.globalFontSizeInPx
		? Number(appearancePreference.globalFontSizeInPx?.replace("px", ""))
		: 16;

	const displayTheme =
		appearancePreference.theme === "Dark"
			? getBasicTheme("Dark", fontSize)
			: getBasicTheme("Light", fontSize);

	return <ThemeProvider theme={displayTheme}>{children}</ThemeProvider>;
};
