// Generated from /Users/yatfuchan/Projects/ha/postgres-ddl-parser/src/newsyntax/Weighting.g4 by ANTLR 4.13.1

import { AbstractParseTreeVisitor } from "antlr4ng";

import { ExprContext } from "./WeightingParser.js";
import { DirectiveContext } from "./WeightingParser.js";
import { DirectiveItemContext } from "./WeightingParser.js";
import { FlagDirectiveContext } from "./WeightingParser.js";
import { ValueDirectiveContext } from "./WeightingParser.js";
import { WeightingGroupContext } from "./WeightingParser.js";
import { GroupSubjectsContext } from "./WeightingParser.js";
import { SimpleSubjectContext } from "./WeightingParser.js";
import { AltNoCountContext } from "./WeightingParser.js";
import { AltMinCountContext } from "./WeightingParser.js";
import { AltMaxCountContext } from "./WeightingParser.js";

/**
 * This interface defines a complete generic visitor for a parse tree produced
 * by `WeightingParser`.
 *
 * @param <Result> The return type of the visit operation. Use `void` for
 * operations with no return type.
 */
export class WeightingVisitor<Result> extends AbstractParseTreeVisitor<Result> {
	/**
	 * Visit a parse tree produced by `WeightingParser.expr`.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	visitExpr?: (ctx: ExprContext) => Result;
	/**
	 * Visit a parse tree produced by `WeightingParser.directive`.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	visitDirective?: (ctx: DirectiveContext) => Result;
	/**
	 * Visit a parse tree produced by `WeightingParser.directiveItem`.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	visitDirectiveItem?: (ctx: DirectiveItemContext) => Result;
	/**
	 * Visit a parse tree produced by `WeightingParser.flagDirective`.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	visitFlagDirective?: (ctx: FlagDirectiveContext) => Result;
	/**
	 * Visit a parse tree produced by `WeightingParser.valueDirective`.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	visitValueDirective?: (ctx: ValueDirectiveContext) => Result;
	/**
	 * Visit a parse tree produced by `WeightingParser.weightingGroup`.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	visitWeightingGroup?: (ctx: WeightingGroupContext) => Result;
	/**
	 * Visit a parse tree produced by `WeightingParser.groupSubjects`.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	visitGroupSubjects?: (ctx: GroupSubjectsContext) => Result;
	/**
	 * Visit a parse tree produced by `WeightingParser.simpleSubject`.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	visitSimpleSubject?: (ctx: SimpleSubjectContext) => Result;
	/**
	 * Visit a parse tree produced by the `altNoCount`
	 * labeled alternative in `WeightingParser.alternativeSubject`.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	visitAltNoCount?: (ctx: AltNoCountContext) => Result;
	/**
	 * Visit a parse tree produced by the `altMinCount`
	 * labeled alternative in `WeightingParser.alternativeSubject`.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	visitAltMinCount?: (ctx: AltMinCountContext) => Result;
	/**
	 * Visit a parse tree produced by the `altMaxCount`
	 * labeled alternative in `WeightingParser.alternativeSubject`.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	visitAltMaxCount?: (ctx: AltMaxCountContext) => Result;
}
