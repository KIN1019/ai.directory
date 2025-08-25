import { generateStaticParamsFor, importPage } from 'nextra/pages'
import { useMDXComponents as getMDXComponents } from '@/mdx-components'
import { ScrollProgress } from "@/components/magicui/scroll-progress";
 
export const generateStaticParams = generateStaticParamsFor('mdxPath')
 
export async function generateMetadata(props: { params: Promise<{ mdxPath: string[] }> }) {
  const params = await props.params
  const { metadata } = await importPage(params.mdxPath)
  return metadata
}
 
const Wrapper = getMDXComponents({}).wrapper
 
export default async function Page(props: { params: Promise<{ mdxPath: string[] }> }) {
  const params = await props.params
  const result = await importPage(params.mdxPath)
  const { default: MDXContent, toc, metadata } = result
  return (
    <Wrapper toc={toc} metadata={metadata}>
      <ScrollProgress className="top-[68px]" />
      <MDXContent {...props} params={params} />
    </Wrapper>
  )
}