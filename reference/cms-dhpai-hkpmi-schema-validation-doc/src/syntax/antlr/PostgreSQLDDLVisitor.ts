// Generated from /Users/yatfuchan/Projects/ha/postgres-ddl-parser/src/syntax/PostgreSQLDDL.g4 by ANTLR 4.13.1

import { AbstractParseTreeVisitor } from "antlr4ng";

import { FileContext } from "./PostgreSQLDDLParser.js";
import { CreateTableContext } from "./PostgreSQLDDLParser.js";
import { TableNameContext } from "./PostgreSQLDDLParser.js";
import { TableColumnsContext } from "./PostgreSQLDDLParser.js";
import { TableColumnContext } from "./PostgreSQLDDLParser.js";
import { ColumnNameContext } from "./PostgreSQLDDLParser.js";
import { TypecastContext } from "./PostgreSQLDDLParser.js";
import { DataTypeContext } from "./PostgreSQLDDLParser.js";
import { ColumnConstraintContext } from "./PostgreSQLDDLParser.js";

/**
 * This interface defines a complete generic visitor for a parse tree produced
 * by `PostgreSQLDDLParser`.
 *
 * @param <Result> The return type of the visit operation. Use `void` for
 * operations with no return type.
 */
export class PostgreSQLDDLVisitor<
	Result,
> extends AbstractParseTreeVisitor<Result> {
	/**
	 * Visit a parse tree produced by `PostgreSQLDDLParser.file`.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	visitFile?: (ctx: FileContext) => Result;
	/**
	 * Visit a parse tree produced by `PostgreSQLDDLParser.createTable`.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	visitCreateTable?: (ctx: CreateTableContext) => Result;
	/**
	 * Visit a parse tree produced by `PostgreSQLDDLParser.tableName`.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	visitTableName?: (ctx: TableNameContext) => Result;
	/**
	 * Visit a parse tree produced by `PostgreSQLDDLParser.tableColumns`.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	visitTableColumns?: (ctx: TableColumnsContext) => Result;
	/**
	 * Visit a parse tree produced by `PostgreSQLDDLParser.tableColumn`.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	visitTableColumn?: (ctx: TableColumnContext) => Result;
	/**
	 * Visit a parse tree produced by `PostgreSQLDDLParser.columnName`.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	visitColumnName?: (ctx: ColumnNameContext) => Result;
	/**
	 * Visit a parse tree produced by `PostgreSQLDDLParser.typecast`.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	visitTypecast?: (ctx: TypecastContext) => Result;
	/**
	 * Visit a parse tree produced by `PostgreSQLDDLParser.dataType`.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	visitDataType?: (ctx: DataTypeContext) => Result;
	/**
	 * Visit a parse tree produced by `PostgreSQLDDLParser.columnConstraint`.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	visitColumnConstraint?: (ctx: ColumnConstraintContext) => Result;
}
