import { NextResponse } from "next/server";
import axios from "axios";
import https from "https";

export const dynamic = "force-dynamic";

// Create an HTTPS agent that ignores SSL certificate errors (for HA internal servers with self-signed certs)
const httpsAgent = new https.Agent({
	rejectUnauthorized: false,
});

export async function GET(request: Request) {
	const { searchParams } = new URL(request.url);
	const url = searchParams.get("url");

	if (!url) {
		return NextResponse.json({ error: "URL parameter is required" }, { status: 400 });
	}

	try {
		const response = await axios.get(url, {
			headers: {
				'User-Agent': 'Mozilla/5.0',
			},
			httpsAgent: httpsAgent,
			timeout: 30000, // 30 second timeout
		});

		return NextResponse.json({ content: response.data });
	} catch (error) {
		console.error("Error fetching llms.txt:", error);
		
		if (axios.isAxiosError(error)) {
			const status = error.response?.status || 500;
			const statusText = error.response?.statusText || "Unknown error";
			const errorData = error.response?.data;
			
			console.error(`Failed to fetch from ${url}: ${status} ${statusText}`, errorData);
			
			return NextResponse.json(
				{ error: `Failed to fetch: ${status} ${statusText}` },
				{ status: 500 },
			);
		}
		
		const errorMessage = error instanceof Error ? error.message : "Failed to fetch llms.txt content";
		return NextResponse.json(
			{ error: errorMessage },
			{ status: 500 },
		);
	}
}

