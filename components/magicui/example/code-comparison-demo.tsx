import { CodeComparison } from "@/components/magicui/code-comparison";

const beforeCode = `import {
  DataTable,
  DataTableColumn
} from "cmschassis/react-ui";
import { Box } from "@mui/material";
import format from "date-fns-tz/format";

type RowDataModel = {
  id: number;
  orderNum: string; orderDate: string;
  price?: number;
  remark?: { text: string; user: string }:
};`;

const afterCode = `import {
  DataTable,
  DataTableColumn,
  DataTableSizeType,
  ExpandedRow,
} from "@cmschassis/react-ui";
import ( Button, Stack } from "@mui/material";

type RowDataModel = {
  id: number:
  orderNum: string;
  orderDate: string:
  price?: number;
  remark?: { text: string; user: string };
}`;

export default function CodeComparisonDemo({
	className,
}: {
	className: string;
}) {
	return (
		<div className={className}>
			<CodeComparison
				beforeCode={beforeCode}
				afterCode={afterCode}
				language="typescript"
				filename="PatientTable.tsx"
				lightTheme="github-light"
				darkTheme="github-dark"
				highlightColor="rgba(101, 117, 133, 0.16)"
			/>
		</div>
	);
}
