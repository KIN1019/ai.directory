// Generated from /Users/yatfuchan/Projects/ha/postgres-ddl-parser/src/syntax/PostgreSQLDDL.g4 by ANTLR 4.13.1

import {
	ErrorNode,
	ParseTreeListener,
	ParserRuleContext,
	TerminalNode,
} from "antlr4ng";

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
 * This interface defines a complete listener for a parse tree produced by
 * `PostgreSQLDDLParser`.
 */
export class PostgreSQLDDLListener implements ParseTreeListener {
	/**
	 * Enter a parse tree produced by `PostgreSQLDDLParser.file`.
	 * @param ctx the parse tree
	 */
	enterFile?: (ctx: FileContext) => void;
	/**
	 * Exit a parse tree produced by `PostgreSQLDDLParser.file`.
	 * @param ctx the parse tree
	 */
	exitFile?: (ctx: FileContext) => void;
	/**
	 * Enter a parse tree produced by `PostgreSQLDDLParser.createTable`.
	 * @param ctx the parse tree
	 */
	enterCreateTable?: (ctx: CreateTableContext) => void;
	/**
	 * Exit a parse tree produced by `PostgreSQLDDLParser.createTable`.
	 * @param ctx the parse tree
	 */
	exitCreateTable?: (ctx: CreateTableContext) => void;
	/**
	 * Enter a parse tree produced by `PostgreSQLDDLParser.tableName`.
	 * @param ctx the parse tree
	 */
	enterTableName?: (ctx: TableNameContext) => void;
	/**
	 * Exit a parse tree produced by `PostgreSQLDDLParser.tableName`.
	 * @param ctx the parse tree
	 */
	exitTableName?: (ctx: TableNameContext) => void;
	/**
	 * Enter a parse tree produced by `PostgreSQLDDLParser.tableColumns`.
	 * @param ctx the parse tree
	 */
	enterTableColumns?: (ctx: TableColumnsContext) => void;
	/**
	 * Exit a parse tree produced by `PostgreSQLDDLParser.tableColumns`.
	 * @param ctx the parse tree
	 */
	exitTableColumns?: (ctx: TableColumnsContext) => void;
	/**
	 * Enter a parse tree produced by `PostgreSQLDDLParser.tableColumn`.
	 * @param ctx the parse tree
	 */
	enterTableColumn?: (ctx: TableColumnContext) => void;
	/**
	 * Exit a parse tree produced by `PostgreSQLDDLParser.tableColumn`.
	 * @param ctx the parse tree
	 */
	exitTableColumn?: (ctx: TableColumnContext) => void;
	/**
	 * Enter a parse tree produced by `PostgreSQLDDLParser.columnName`.
	 * @param ctx the parse tree
	 */
	enterColumnName?: (ctx: ColumnNameContext) => void;
	/**
	 * Exit a parse tree produced by `PostgreSQLDDLParser.columnName`.
	 * @param ctx the parse tree
	 */
	exitColumnName?: (ctx: ColumnNameContext) => void;
	/**
	 * Enter a parse tree produced by `PostgreSQLDDLParser.typecast`.
	 * @param ctx the parse tree
	 */
	enterTypecast?: (ctx: TypecastContext) => void;
	/**
	 * Exit a parse tree produced by `PostgreSQLDDLParser.typecast`.
	 * @param ctx the parse tree
	 */
	exitTypecast?: (ctx: TypecastContext) => void;
	/**
	 * Enter a parse tree produced by `PostgreSQLDDLParser.dataType`.
	 * @param ctx the parse tree
	 */
	enterDataType?: (ctx: DataTypeContext) => void;
	/**
	 * Exit a parse tree produced by `PostgreSQLDDLParser.dataType`.
	 * @param ctx the parse tree
	 */
	exitDataType?: (ctx: DataTypeContext) => void;
	/**
	 * Enter a parse tree produced by `PostgreSQLDDLParser.columnConstraint`.
	 * @param ctx the parse tree
	 */
	enterColumnConstraint?: (ctx: ColumnConstraintContext) => void;
	/**
	 * Exit a parse tree produced by `PostgreSQLDDLParser.columnConstraint`.
	 * @param ctx the parse tree
	 */
	exitColumnConstraint?: (ctx: ColumnConstraintContext) => void;

	visitTerminal(node: TerminalNode): void {}
	visitErrorNode(node: ErrorNode): void {}
	enterEveryRule(node: ParserRuleContext): void {}
	exitEveryRule(node: ParserRuleContext): void {}
}
