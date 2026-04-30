import { PostgreSQLDDLListener } from "./antlr/PostgreSQLDDLListener";
import type {
	CreateTableContext,
	TableColumnContext,
} from "./antlr/PostgreSQLDDLParser";

export class CreateTableListener extends PostgreSQLDDLListener {
	tables: { [key: string]: any } = {};
	currentTable: string | null = null;

	enterCreateTable?: ((ctx: CreateTableContext) => void) | undefined = (
		ctx,
	) => {
		const tableName = ctx
			.tableName()
			.ID()
			.getText()
			.replace(/"/g, "")
			.toLowerCase();
		this.tables[tableName] = {};
		this.currentTable = tableName;
	};

	exitCreateTable?: ((ctx: CreateTableContext) => void) | undefined = () => {
		this.currentTable = null;
	};

	enterTableColumn?: ((ctx: TableColumnContext) => void) | undefined = (
		ctx,
	) => {
		const currentColumn = ctx.columnName().ID().getText().toLowerCase();
		const dataType = ctx.dataType().ID().getText().toLowerCase();
		const dataTypeArguments = ctx
			.dataType()
			.NUMBER()
			.map((arg) => arg.getText().toLowerCase());
		const dataTypeConstraintString =
			dataTypeArguments.length === 0 ? "" : `(${dataTypeArguments.join(", ")})`;
		const dataTypeString = `${dataType}${dataTypeConstraintString}`;
		this.tables[this.currentTable!][currentColumn] = dataTypeString;
	};
}
