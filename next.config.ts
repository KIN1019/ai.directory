import type { NextConfig } from "next";
import nextra from 'nextra'

const withNextra = nextra({
	contentDirBasePath: '/docs',
});

const nextConfig: NextConfig = {
	/* config options here */
};

export default withNextra(nextConfig);
