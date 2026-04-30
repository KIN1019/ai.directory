import { PrintService } from "@cmschassis/cmsaf-js";
import { PdfViewer } from "@ha/pdf-viewer";
import { Box, Button, Divider, Grid, Paper, Typography } from "@mui/material";
import { format } from "date-fns";
import cms from "../../cms-plugin/cms-api-provider";
import pluginId from "../../cms-plugin/pluginId";

export const ExamplesView = () => {
	/**
	 * PDF viewer, CCP, and cmsjs alert dialog section.
	 */
	// const pdf =
	// "https://cms-pdfviewer-demo-app-cms-corp-sit.tstcld61.server.ha.org.hk/pdf/0.pdf";
	const pdf =
		"https://cms-cmsaf-corp-svc-sit.cmseap.server.ha.org.hk/api/v1/pdfeng/imgDoc?hospCode=VH&imageNo=499209";

	const onPrint = (document: string | Blob) => {
		PrintService.printCcp(document).then((res) => {
			console.log(res);
			if (!res.success) openViewAlertDialog(res);
			if (res.success)
				cms.api.ui.showLowPriorityAlert({ content: "Sent to CCP" });
		});
	};

	// Example usage of cms.api.ui.showViewAlertDialog method to show view alert dialog.
	// For more information please see https://hagithub.home/pages/CMSCHASSIS/cms-js-lib/docs/modules/ui.html
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	const openViewAlertDialog = (res: any) => {
		const date = res?.date ? new Date(res?.date) : new Date();

		cms.api.ui.showViewAlertDialog(
			"examples-view",
			{
				title: "Error",
				icon: "error",
				content: "An Error has occured.",
				additionalInfo: {
					Date: format(
						!isNaN(date.getTime()) ? date : new Date(),
						"dd-MMM-yyyy HH:mm:ss",
					),
					Module: res.module || "CMS Example - ccp",
					"Login ID":
						cms.api.session.get().user.corpId ||
						cms.api.session.get().user.cmsUserId,
					"Correlation ID": res.correlationId || "(Empty)",
					"Transaction ID": res.transactionID || "(Empty)",
					Cause: res.message,
					Status: res.statusCode || "(Empty)",
				},
				actions: ["OK"],
			},
			pluginId,
		);
	};
	// End of PDF viewer, CCP, and cmsjs alert dialog section.

	return (
		<Paper
			sx={{
				paddingX: 50,
				paddingY: 40,
				paddingBottom: 80,
				overflowY: "auto!important",
			}}
		>
			<Grid container rowGap={56}>
				<Grid item xs={12}>
					<Typography variant="h1">PDF Viewer</Typography>
					<Divider />
					<Box
						sx={{
							marginTop: 14,
							border: "1px solid black",
							".PdfApp": { height: "100vh" },
						}}
					>
						<PdfViewer url={pdf} enablePrint={true} onPrint={onPrint} />
					</Box>
				</Grid>

				<Grid item xs={12}>
					<Typography variant="h1">Printing via CCP</Typography>
					<Divider />
					<Box sx={{ marginTop: 14 }}>
						<Button onClick={() => onPrint(pdf)}>Print above PDF</Button>
					</Box>
				</Grid>
			</Grid>
		</Paper>
	);
};
