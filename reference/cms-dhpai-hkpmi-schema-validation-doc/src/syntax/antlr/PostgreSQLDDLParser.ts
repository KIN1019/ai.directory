// Generated from /Users/yatfuchan/Projects/ha/postgres-ddl-parser/src/syntax/PostgreSQLDDL.g4 by ANTLR 4.13.1

import * as antlr from "antlr4ng";
import { Token } from "antlr4ng";

import { PostgreSQLDDLListener } from "./PostgreSQLDDLListener.js";
import { PostgreSQLDDLVisitor } from "./PostgreSQLDDLVisitor.js";

// for running tests with parameters, TODO: discuss strategy for typed parameters in CI
// eslint-disable-next-line no-unused-vars
type int = number;

export class PostgreSQLDDLParser extends antlr.Parser {
	public static readonly T__0 = 1;
	public static readonly T__1 = 2;
	public static readonly T__2 = 3;
	public static readonly T__3 = 4;
	public static readonly T__4 = 5;
	public static readonly T__5 = 6;
	public static readonly T__6 = 7;
	public static readonly CREATE = 8;
	public static readonly TABLE = 9;
	public static readonly ID = 10;
	public static readonly ID_ = 11;
	public static readonly NUMBER = 12;
	public static readonly WS = 13;
	public static readonly COMMENT = 14;
	public static readonly MULTILINE_COMMENT = 15;
	public static readonly RULE_file = 0;
	public static readonly RULE_createTable = 1;
	public static readonly RULE_tableName = 2;
	public static readonly RULE_tableColumns = 3;
	public static readonly RULE_tableColumn = 4;
	public static readonly RULE_columnName = 5;
	public static readonly RULE_typecast = 6;
	public static readonly RULE_dataType = 7;
	public static readonly RULE_columnConstraint = 8;

	public static readonly literalNames = [
		null,
		"'('",
		"')'",
		"';'",
		"','",
		"'\"'",
		"'''",
		"':'",
	];

	public static readonly symbolicNames = [
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		"CREATE",
		"TABLE",
		"ID",
		"ID_",
		"NUMBER",
		"WS",
		"COMMENT",
		"MULTILINE_COMMENT",
	];
	public static readonly ruleNames = [
		"file",
		"createTable",
		"tableName",
		"tableColumns",
		"tableColumn",
		"columnName",
		"typecast",
		"dataType",
		"columnConstraint",
	];

	public get grammarFileName(): string {
		return "PostgreSQLDDL.g4";
	}
	public get literalNames(): (string | null)[] {
		return PostgreSQLDDLParser.literalNames;
	}
	public get symbolicNames(): (string | null)[] {
		return PostgreSQLDDLParser.symbolicNames;
	}
	public get ruleNames(): string[] {
		return PostgreSQLDDLParser.ruleNames;
	}
	public get serializedATN(): number[] {
		return PostgreSQLDDLParser._serializedATN;
	}

	protected createFailedPredicateException(
		predicate?: string,
		message?: string,
	): antlr.FailedPredicateException {
		return new antlr.FailedPredicateException(this, predicate, message);
	}

	public constructor(input: antlr.TokenStream) {
		super(input);
		this.interpreter = new antlr.ParserATNSimulator(
			this,
			PostgreSQLDDLParser._ATN,
			PostgreSQLDDLParser.decisionsToDFA,
			new antlr.PredictionContextCache(),
		);
	}
	public file(): FileContext {
		let localContext = new FileContext(this.context, this.state);
		this.enterRule(localContext, 0, PostgreSQLDDLParser.RULE_file);
		try {
			let alternative: number;
			this.enterOuterAlt(localContext, 1);
			{
				this.state = 22;
				this.errorHandler.sync(this);
				alternative = this.interpreter.adaptivePredict(
					this.tokenStream,
					1,
					this.context,
				);
				while (
					alternative !== 1 &&
					alternative !== antlr.ATN.INVALID_ALT_NUMBER
				) {
					if (alternative === 1 + 1) {
						{
							this.state = 20;
							this.errorHandler.sync(this);
							switch (
								this.interpreter.adaptivePredict(
									this.tokenStream,
									0,
									this.context,
								)
							) {
								case 1:
									{
										this.state = 18;
										this.createTable();
									}
									break;
								case 2:
									{
										this.state = 19;
										this.matchWildcard();
									}
									break;
							}
						}
					}
					this.state = 24;
					this.errorHandler.sync(this);
					alternative = this.interpreter.adaptivePredict(
						this.tokenStream,
						1,
						this.context,
					);
				}
				this.state = 25;
				this.match(PostgreSQLDDLParser.EOF);
			}
		} catch (re) {
			if (re instanceof antlr.RecognitionException) {
				this.errorHandler.reportError(this, re);
				this.errorHandler.recover(this, re);
			} else {
				throw re;
			}
		} finally {
			this.exitRule();
		}
		return localContext;
	}
	public createTable(): CreateTableContext {
		let localContext = new CreateTableContext(this.context, this.state);
		this.enterRule(localContext, 2, PostgreSQLDDLParser.RULE_createTable);
		let _la: number;
		try {
			let alternative: number;
			this.enterOuterAlt(localContext, 1);
			{
				this.state = 27;
				this.match(PostgreSQLDDLParser.CREATE);
				this.state = 31;
				this.errorHandler.sync(this);
				_la = this.tokenStream.LA(1);
				while (_la === 10) {
					{
						{
							this.state = 28;
							this.match(PostgreSQLDDLParser.ID);
						}
					}
					this.state = 33;
					this.errorHandler.sync(this);
					_la = this.tokenStream.LA(1);
				}
				this.state = 34;
				this.match(PostgreSQLDDLParser.TABLE);
				this.state = 38;
				this.errorHandler.sync(this);
				alternative = this.interpreter.adaptivePredict(
					this.tokenStream,
					3,
					this.context,
				);
				while (
					alternative !== 2 &&
					alternative !== antlr.ATN.INVALID_ALT_NUMBER
				) {
					if (alternative === 1) {
						{
							{
								this.state = 35;
								this.match(PostgreSQLDDLParser.ID);
							}
						}
					}
					this.state = 40;
					this.errorHandler.sync(this);
					alternative = this.interpreter.adaptivePredict(
						this.tokenStream,
						3,
						this.context,
					);
				}
				this.state = 41;
				this.tableName();
				this.state = 42;
				this.match(PostgreSQLDDLParser.T__0);
				this.state = 43;
				this.tableColumns();
				this.state = 44;
				this.match(PostgreSQLDDLParser.T__1);
				this.state = 45;
				this.match(PostgreSQLDDLParser.T__2);
			}
		} catch (re) {
			if (re instanceof antlr.RecognitionException) {
				this.errorHandler.reportError(this, re);
				this.errorHandler.recover(this, re);
			} else {
				throw re;
			}
		} finally {
			this.exitRule();
		}
		return localContext;
	}
	public tableName(): TableNameContext {
		let localContext = new TableNameContext(this.context, this.state);
		this.enterRule(localContext, 4, PostgreSQLDDLParser.RULE_tableName);
		try {
			this.enterOuterAlt(localContext, 1);
			{
				this.state = 47;
				this.match(PostgreSQLDDLParser.ID);
			}
		} catch (re) {
			if (re instanceof antlr.RecognitionException) {
				this.errorHandler.reportError(this, re);
				this.errorHandler.recover(this, re);
			} else {
				throw re;
			}
		} finally {
			this.exitRule();
		}
		return localContext;
	}
	public tableColumns(): TableColumnsContext {
		let localContext = new TableColumnsContext(this.context, this.state);
		this.enterRule(localContext, 6, PostgreSQLDDLParser.RULE_tableColumns);
		let _la: number;
		try {
			this.enterOuterAlt(localContext, 1);
			{
				this.state = 49;
				this.tableColumn();
				this.state = 54;
				this.errorHandler.sync(this);
				_la = this.tokenStream.LA(1);
				while (_la === 4) {
					{
						{
							this.state = 50;
							this.match(PostgreSQLDDLParser.T__3);
							this.state = 51;
							this.tableColumn();
						}
					}
					this.state = 56;
					this.errorHandler.sync(this);
					_la = this.tokenStream.LA(1);
				}
			}
		} catch (re) {
			if (re instanceof antlr.RecognitionException) {
				this.errorHandler.reportError(this, re);
				this.errorHandler.recover(this, re);
			} else {
				throw re;
			}
		} finally {
			this.exitRule();
		}
		return localContext;
	}
	public tableColumn(): TableColumnContext {
		let localContext = new TableColumnContext(this.context, this.state);
		this.enterRule(localContext, 8, PostgreSQLDDLParser.RULE_tableColumn);
		let _la: number;
		try {
			this.enterOuterAlt(localContext, 1);
			{
				this.state = 57;
				this.columnName();
				this.state = 58;
				this.dataType();
				this.state = 62;
				this.errorHandler.sync(this);
				_la = this.tokenStream.LA(1);
				while (_la === 10) {
					{
						{
							this.state = 59;
							this.match(PostgreSQLDDLParser.ID);
						}
					}
					this.state = 64;
					this.errorHandler.sync(this);
					_la = this.tokenStream.LA(1);
				}
			}
		} catch (re) {
			if (re instanceof antlr.RecognitionException) {
				this.errorHandler.reportError(this, re);
				this.errorHandler.recover(this, re);
			} else {
				throw re;
			}
		} finally {
			this.exitRule();
		}
		return localContext;
	}
	public columnName(): ColumnNameContext {
		let localContext = new ColumnNameContext(this.context, this.state);
		this.enterRule(localContext, 10, PostgreSQLDDLParser.RULE_columnName);
		try {
			this.state = 75;
			this.errorHandler.sync(this);
			switch (
				this.interpreter.adaptivePredict(this.tokenStream, 6, this.context)
			) {
				case 1:
					this.enterOuterAlt(localContext, 1);
					{
						this.state = 65;
						this.match(PostgreSQLDDLParser.ID);
					}
					break;
				case 2:
					this.enterOuterAlt(localContext, 2);
					{
						this.state = 66;
						this.match(PostgreSQLDDLParser.T__4);
						this.state = 67;
						this.match(PostgreSQLDDLParser.ID);
						this.state = 68;
						this.match(PostgreSQLDDLParser.T__4);
					}
					break;
				case 3:
					this.enterOuterAlt(localContext, 3);
					{
						this.state = 69;
						this.match(PostgreSQLDDLParser.T__5);
						this.state = 70;
						this.match(PostgreSQLDDLParser.ID);
						this.state = 71;
						this.match(PostgreSQLDDLParser.T__5);
					}
					break;
				case 4:
					this.enterOuterAlt(localContext, 4);
					{
						this.state = 72;
						this.match(PostgreSQLDDLParser.ID);
						this.state = 73;
						this.match(PostgreSQLDDLParser.T__6);
						this.state = 74;
						this.typecast();
					}
					break;
			}
		} catch (re) {
			if (re instanceof antlr.RecognitionException) {
				this.errorHandler.reportError(this, re);
				this.errorHandler.recover(this, re);
			} else {
				throw re;
			}
		} finally {
			this.exitRule();
		}
		return localContext;
	}
	public typecast(): TypecastContext {
		let localContext = new TypecastContext(this.context, this.state);
		this.enterRule(localContext, 12, PostgreSQLDDLParser.RULE_typecast);
		try {
			this.enterOuterAlt(localContext, 1);
			{
				this.state = 77;
				this.match(PostgreSQLDDLParser.ID);
			}
		} catch (re) {
			if (re instanceof antlr.RecognitionException) {
				this.errorHandler.reportError(this, re);
				this.errorHandler.recover(this, re);
			} else {
				throw re;
			}
		} finally {
			this.exitRule();
		}
		return localContext;
	}
	public dataType(): DataTypeContext {
		let localContext = new DataTypeContext(this.context, this.state);
		this.enterRule(localContext, 14, PostgreSQLDDLParser.RULE_dataType);
		let _la: number;
		try {
			this.enterOuterAlt(localContext, 1);
			{
				this.state = 79;
				this.match(PostgreSQLDDLParser.ID);
				this.state = 90;
				this.errorHandler.sync(this);
				_la = this.tokenStream.LA(1);
				if (_la === 1) {
					{
						this.state = 80;
						this.match(PostgreSQLDDLParser.T__0);
						this.state = 81;
						this.match(PostgreSQLDDLParser.NUMBER);
						this.state = 86;
						this.errorHandler.sync(this);
						_la = this.tokenStream.LA(1);
						while (_la === 4) {
							{
								{
									this.state = 82;
									this.match(PostgreSQLDDLParser.T__3);
									this.state = 83;
									this.match(PostgreSQLDDLParser.NUMBER);
								}
							}
							this.state = 88;
							this.errorHandler.sync(this);
							_la = this.tokenStream.LA(1);
						}
						this.state = 89;
						this.match(PostgreSQLDDLParser.T__1);
					}
				}
			}
		} catch (re) {
			if (re instanceof antlr.RecognitionException) {
				this.errorHandler.reportError(this, re);
				this.errorHandler.recover(this, re);
			} else {
				throw re;
			}
		} finally {
			this.exitRule();
		}
		return localContext;
	}
	public columnConstraint(): ColumnConstraintContext {
		let localContext = new ColumnConstraintContext(this.context, this.state);
		this.enterRule(localContext, 16, PostgreSQLDDLParser.RULE_columnConstraint);
		let _la: number;
		try {
			this.enterOuterAlt(localContext, 1);
			{
				this.state = 95;
				this.errorHandler.sync(this);
				_la = this.tokenStream.LA(1);
				while (_la === 10) {
					{
						{
							this.state = 92;
							this.match(PostgreSQLDDLParser.ID);
						}
					}
					this.state = 97;
					this.errorHandler.sync(this);
					_la = this.tokenStream.LA(1);
				}
			}
		} catch (re) {
			if (re instanceof antlr.RecognitionException) {
				this.errorHandler.reportError(this, re);
				this.errorHandler.recover(this, re);
			} else {
				throw re;
			}
		} finally {
			this.exitRule();
		}
		return localContext;
	}

	public static readonly _serializedATN: number[] = [
		4, 1, 15, 99, 2, 0, 7, 0, 2, 1, 7, 1, 2, 2, 7, 2, 2, 3, 7, 3, 2, 4, 7, 4, 2,
		5, 7, 5, 2, 6, 7, 6, 2, 7, 7, 7, 2, 8, 7, 8, 1, 0, 1, 0, 5, 0, 21, 8, 0, 10,
		0, 12, 0, 24, 9, 0, 1, 0, 1, 0, 1, 1, 1, 1, 5, 1, 30, 8, 1, 10, 1, 12, 1,
		33, 9, 1, 1, 1, 1, 1, 5, 1, 37, 8, 1, 10, 1, 12, 1, 40, 9, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 2, 1, 3, 1, 3, 1, 3, 5, 3, 53, 8, 3, 10, 3,
		12, 3, 56, 9, 3, 1, 4, 1, 4, 1, 4, 5, 4, 61, 8, 4, 10, 4, 12, 4, 64, 9, 4,
		1, 5, 1, 5, 1, 5, 1, 5, 1, 5, 1, 5, 1, 5, 1, 5, 1, 5, 1, 5, 3, 5, 76, 8, 5,
		1, 6, 1, 6, 1, 7, 1, 7, 1, 7, 1, 7, 1, 7, 5, 7, 85, 8, 7, 10, 7, 12, 7, 88,
		9, 7, 1, 7, 3, 7, 91, 8, 7, 1, 8, 5, 8, 94, 8, 8, 10, 8, 12, 8, 97, 9, 8, 1,
		8, 1, 22, 0, 9, 0, 2, 4, 6, 8, 10, 12, 14, 16, 0, 0, 101, 0, 22, 1, 0, 0, 0,
		2, 27, 1, 0, 0, 0, 4, 47, 1, 0, 0, 0, 6, 49, 1, 0, 0, 0, 8, 57, 1, 0, 0, 0,
		10, 75, 1, 0, 0, 0, 12, 77, 1, 0, 0, 0, 14, 79, 1, 0, 0, 0, 16, 95, 1, 0, 0,
		0, 18, 21, 3, 2, 1, 0, 19, 21, 9, 0, 0, 0, 20, 18, 1, 0, 0, 0, 20, 19, 1, 0,
		0, 0, 21, 24, 1, 0, 0, 0, 22, 23, 1, 0, 0, 0, 22, 20, 1, 0, 0, 0, 23, 25, 1,
		0, 0, 0, 24, 22, 1, 0, 0, 0, 25, 26, 5, 0, 0, 1, 26, 1, 1, 0, 0, 0, 27, 31,
		5, 8, 0, 0, 28, 30, 5, 10, 0, 0, 29, 28, 1, 0, 0, 0, 30, 33, 1, 0, 0, 0, 31,
		29, 1, 0, 0, 0, 31, 32, 1, 0, 0, 0, 32, 34, 1, 0, 0, 0, 33, 31, 1, 0, 0, 0,
		34, 38, 5, 9, 0, 0, 35, 37, 5, 10, 0, 0, 36, 35, 1, 0, 0, 0, 37, 40, 1, 0,
		0, 0, 38, 36, 1, 0, 0, 0, 38, 39, 1, 0, 0, 0, 39, 41, 1, 0, 0, 0, 40, 38, 1,
		0, 0, 0, 41, 42, 3, 4, 2, 0, 42, 43, 5, 1, 0, 0, 43, 44, 3, 6, 3, 0, 44, 45,
		5, 2, 0, 0, 45, 46, 5, 3, 0, 0, 46, 3, 1, 0, 0, 0, 47, 48, 5, 10, 0, 0, 48,
		5, 1, 0, 0, 0, 49, 54, 3, 8, 4, 0, 50, 51, 5, 4, 0, 0, 51, 53, 3, 8, 4, 0,
		52, 50, 1, 0, 0, 0, 53, 56, 1, 0, 0, 0, 54, 52, 1, 0, 0, 0, 54, 55, 1, 0, 0,
		0, 55, 7, 1, 0, 0, 0, 56, 54, 1, 0, 0, 0, 57, 58, 3, 10, 5, 0, 58, 62, 3,
		14, 7, 0, 59, 61, 5, 10, 0, 0, 60, 59, 1, 0, 0, 0, 61, 64, 1, 0, 0, 0, 62,
		60, 1, 0, 0, 0, 62, 63, 1, 0, 0, 0, 63, 9, 1, 0, 0, 0, 64, 62, 1, 0, 0, 0,
		65, 76, 5, 10, 0, 0, 66, 67, 5, 5, 0, 0, 67, 68, 5, 10, 0, 0, 68, 76, 5, 5,
		0, 0, 69, 70, 5, 6, 0, 0, 70, 71, 5, 10, 0, 0, 71, 76, 5, 6, 0, 0, 72, 73,
		5, 10, 0, 0, 73, 74, 5, 7, 0, 0, 74, 76, 3, 12, 6, 0, 75, 65, 1, 0, 0, 0,
		75, 66, 1, 0, 0, 0, 75, 69, 1, 0, 0, 0, 75, 72, 1, 0, 0, 0, 76, 11, 1, 0, 0,
		0, 77, 78, 5, 10, 0, 0, 78, 13, 1, 0, 0, 0, 79, 90, 5, 10, 0, 0, 80, 81, 5,
		1, 0, 0, 81, 86, 5, 12, 0, 0, 82, 83, 5, 4, 0, 0, 83, 85, 5, 12, 0, 0, 84,
		82, 1, 0, 0, 0, 85, 88, 1, 0, 0, 0, 86, 84, 1, 0, 0, 0, 86, 87, 1, 0, 0, 0,
		87, 89, 1, 0, 0, 0, 88, 86, 1, 0, 0, 0, 89, 91, 5, 2, 0, 0, 90, 80, 1, 0, 0,
		0, 90, 91, 1, 0, 0, 0, 91, 15, 1, 0, 0, 0, 92, 94, 5, 10, 0, 0, 93, 92, 1,
		0, 0, 0, 94, 97, 1, 0, 0, 0, 95, 93, 1, 0, 0, 0, 95, 96, 1, 0, 0, 0, 96, 17,
		1, 0, 0, 0, 97, 95, 1, 0, 0, 0, 10, 20, 22, 31, 38, 54, 62, 75, 86, 90, 95,
	];

	private static __ATN: antlr.ATN;
	public static get _ATN(): antlr.ATN {
		if (!PostgreSQLDDLParser.__ATN) {
			PostgreSQLDDLParser.__ATN = new antlr.ATNDeserializer().deserialize(
				PostgreSQLDDLParser._serializedATN,
			);
		}

		return PostgreSQLDDLParser.__ATN;
	}

	private static readonly vocabulary = new antlr.Vocabulary(
		PostgreSQLDDLParser.literalNames,
		PostgreSQLDDLParser.symbolicNames,
		[],
	);

	public override get vocabulary(): antlr.Vocabulary {
		return PostgreSQLDDLParser.vocabulary;
	}

	private static readonly decisionsToDFA =
		PostgreSQLDDLParser._ATN.decisionToState.map(
			(ds: antlr.DecisionState, index: number) => new antlr.DFA(ds, index),
		);
}

export class FileContext extends antlr.ParserRuleContext {
	public constructor(
		parent: antlr.ParserRuleContext | null,
		invokingState: number,
	) {
		super(parent, invokingState);
	}
	public EOF(): antlr.TerminalNode {
		return this.getToken(PostgreSQLDDLParser.EOF, 0)!;
	}
	public createTable(): CreateTableContext[];
	public createTable(i: number): CreateTableContext | null;
	public createTable(
		i?: number,
	): CreateTableContext[] | CreateTableContext | null {
		if (i === undefined) {
			return this.getRuleContexts(CreateTableContext);
		}

		return this.getRuleContext(i, CreateTableContext);
	}
	public override get ruleIndex(): number {
		return PostgreSQLDDLParser.RULE_file;
	}
	public override enterRule(listener: PostgreSQLDDLListener): void {
		if (listener.enterFile) {
			listener.enterFile(this);
		}
	}
	public override exitRule(listener: PostgreSQLDDLListener): void {
		if (listener.exitFile) {
			listener.exitFile(this);
		}
	}
	public override accept<Result>(
		visitor: PostgreSQLDDLVisitor<Result>,
	): Result | null {
		if (visitor.visitFile) {
			return visitor.visitFile(this);
		} else {
			return visitor.visitChildren(this);
		}
	}
}

export class CreateTableContext extends antlr.ParserRuleContext {
	public constructor(
		parent: antlr.ParserRuleContext | null,
		invokingState: number,
	) {
		super(parent, invokingState);
	}
	public CREATE(): antlr.TerminalNode {
		return this.getToken(PostgreSQLDDLParser.CREATE, 0)!;
	}
	public TABLE(): antlr.TerminalNode {
		return this.getToken(PostgreSQLDDLParser.TABLE, 0)!;
	}
	public tableName(): TableNameContext {
		return this.getRuleContext(0, TableNameContext)!;
	}
	public tableColumns(): TableColumnsContext {
		return this.getRuleContext(0, TableColumnsContext)!;
	}
	public ID(): antlr.TerminalNode[];
	public ID(i: number): antlr.TerminalNode | null;
	public ID(i?: number): antlr.TerminalNode | null | antlr.TerminalNode[] {
		if (i === undefined) {
			return this.getTokens(PostgreSQLDDLParser.ID);
		} else {
			return this.getToken(PostgreSQLDDLParser.ID, i);
		}
	}
	public override get ruleIndex(): number {
		return PostgreSQLDDLParser.RULE_createTable;
	}
	public override enterRule(listener: PostgreSQLDDLListener): void {
		if (listener.enterCreateTable) {
			listener.enterCreateTable(this);
		}
	}
	public override exitRule(listener: PostgreSQLDDLListener): void {
		if (listener.exitCreateTable) {
			listener.exitCreateTable(this);
		}
	}
	public override accept<Result>(
		visitor: PostgreSQLDDLVisitor<Result>,
	): Result | null {
		if (visitor.visitCreateTable) {
			return visitor.visitCreateTable(this);
		} else {
			return visitor.visitChildren(this);
		}
	}
}

export class TableNameContext extends antlr.ParserRuleContext {
	public constructor(
		parent: antlr.ParserRuleContext | null,
		invokingState: number,
	) {
		super(parent, invokingState);
	}
	public ID(): antlr.TerminalNode {
		return this.getToken(PostgreSQLDDLParser.ID, 0)!;
	}
	public override get ruleIndex(): number {
		return PostgreSQLDDLParser.RULE_tableName;
	}
	public override enterRule(listener: PostgreSQLDDLListener): void {
		if (listener.enterTableName) {
			listener.enterTableName(this);
		}
	}
	public override exitRule(listener: PostgreSQLDDLListener): void {
		if (listener.exitTableName) {
			listener.exitTableName(this);
		}
	}
	public override accept<Result>(
		visitor: PostgreSQLDDLVisitor<Result>,
	): Result | null {
		if (visitor.visitTableName) {
			return visitor.visitTableName(this);
		} else {
			return visitor.visitChildren(this);
		}
	}
}

export class TableColumnsContext extends antlr.ParserRuleContext {
	public constructor(
		parent: antlr.ParserRuleContext | null,
		invokingState: number,
	) {
		super(parent, invokingState);
	}
	public tableColumn(): TableColumnContext[];
	public tableColumn(i: number): TableColumnContext | null;
	public tableColumn(
		i?: number,
	): TableColumnContext[] | TableColumnContext | null {
		if (i === undefined) {
			return this.getRuleContexts(TableColumnContext);
		}

		return this.getRuleContext(i, TableColumnContext);
	}
	public override get ruleIndex(): number {
		return PostgreSQLDDLParser.RULE_tableColumns;
	}
	public override enterRule(listener: PostgreSQLDDLListener): void {
		if (listener.enterTableColumns) {
			listener.enterTableColumns(this);
		}
	}
	public override exitRule(listener: PostgreSQLDDLListener): void {
		if (listener.exitTableColumns) {
			listener.exitTableColumns(this);
		}
	}
	public override accept<Result>(
		visitor: PostgreSQLDDLVisitor<Result>,
	): Result | null {
		if (visitor.visitTableColumns) {
			return visitor.visitTableColumns(this);
		} else {
			return visitor.visitChildren(this);
		}
	}
}

export class TableColumnContext extends antlr.ParserRuleContext {
	public constructor(
		parent: antlr.ParserRuleContext | null,
		invokingState: number,
	) {
		super(parent, invokingState);
	}
	public columnName(): ColumnNameContext {
		return this.getRuleContext(0, ColumnNameContext)!;
	}
	public dataType(): DataTypeContext {
		return this.getRuleContext(0, DataTypeContext)!;
	}
	public ID(): antlr.TerminalNode[];
	public ID(i: number): antlr.TerminalNode | null;
	public ID(i?: number): antlr.TerminalNode | null | antlr.TerminalNode[] {
		if (i === undefined) {
			return this.getTokens(PostgreSQLDDLParser.ID);
		} else {
			return this.getToken(PostgreSQLDDLParser.ID, i);
		}
	}
	public override get ruleIndex(): number {
		return PostgreSQLDDLParser.RULE_tableColumn;
	}
	public override enterRule(listener: PostgreSQLDDLListener): void {
		if (listener.enterTableColumn) {
			listener.enterTableColumn(this);
		}
	}
	public override exitRule(listener: PostgreSQLDDLListener): void {
		if (listener.exitTableColumn) {
			listener.exitTableColumn(this);
		}
	}
	public override accept<Result>(
		visitor: PostgreSQLDDLVisitor<Result>,
	): Result | null {
		if (visitor.visitTableColumn) {
			return visitor.visitTableColumn(this);
		} else {
			return visitor.visitChildren(this);
		}
	}
}

export class ColumnNameContext extends antlr.ParserRuleContext {
	public constructor(
		parent: antlr.ParserRuleContext | null,
		invokingState: number,
	) {
		super(parent, invokingState);
	}
	public ID(): antlr.TerminalNode {
		return this.getToken(PostgreSQLDDLParser.ID, 0)!;
	}
	public typecast(): TypecastContext | null {
		return this.getRuleContext(0, TypecastContext);
	}
	public override get ruleIndex(): number {
		return PostgreSQLDDLParser.RULE_columnName;
	}
	public override enterRule(listener: PostgreSQLDDLListener): void {
		if (listener.enterColumnName) {
			listener.enterColumnName(this);
		}
	}
	public override exitRule(listener: PostgreSQLDDLListener): void {
		if (listener.exitColumnName) {
			listener.exitColumnName(this);
		}
	}
	public override accept<Result>(
		visitor: PostgreSQLDDLVisitor<Result>,
	): Result | null {
		if (visitor.visitColumnName) {
			return visitor.visitColumnName(this);
		} else {
			return visitor.visitChildren(this);
		}
	}
}

export class TypecastContext extends antlr.ParserRuleContext {
	public constructor(
		parent: antlr.ParserRuleContext | null,
		invokingState: number,
	) {
		super(parent, invokingState);
	}
	public ID(): antlr.TerminalNode {
		return this.getToken(PostgreSQLDDLParser.ID, 0)!;
	}
	public override get ruleIndex(): number {
		return PostgreSQLDDLParser.RULE_typecast;
	}
	public override enterRule(listener: PostgreSQLDDLListener): void {
		if (listener.enterTypecast) {
			listener.enterTypecast(this);
		}
	}
	public override exitRule(listener: PostgreSQLDDLListener): void {
		if (listener.exitTypecast) {
			listener.exitTypecast(this);
		}
	}
	public override accept<Result>(
		visitor: PostgreSQLDDLVisitor<Result>,
	): Result | null {
		if (visitor.visitTypecast) {
			return visitor.visitTypecast(this);
		} else {
			return visitor.visitChildren(this);
		}
	}
}

export class DataTypeContext extends antlr.ParserRuleContext {
	public constructor(
		parent: antlr.ParserRuleContext | null,
		invokingState: number,
	) {
		super(parent, invokingState);
	}
	public ID(): antlr.TerminalNode {
		return this.getToken(PostgreSQLDDLParser.ID, 0)!;
	}
	public NUMBER(): antlr.TerminalNode[];
	public NUMBER(i: number): antlr.TerminalNode | null;
	public NUMBER(i?: number): antlr.TerminalNode | null | antlr.TerminalNode[] {
		if (i === undefined) {
			return this.getTokens(PostgreSQLDDLParser.NUMBER);
		} else {
			return this.getToken(PostgreSQLDDLParser.NUMBER, i);
		}
	}
	public override get ruleIndex(): number {
		return PostgreSQLDDLParser.RULE_dataType;
	}
	public override enterRule(listener: PostgreSQLDDLListener): void {
		if (listener.enterDataType) {
			listener.enterDataType(this);
		}
	}
	public override exitRule(listener: PostgreSQLDDLListener): void {
		if (listener.exitDataType) {
			listener.exitDataType(this);
		}
	}
	public override accept<Result>(
		visitor: PostgreSQLDDLVisitor<Result>,
	): Result | null {
		if (visitor.visitDataType) {
			return visitor.visitDataType(this);
		} else {
			return visitor.visitChildren(this);
		}
	}
}

export class ColumnConstraintContext extends antlr.ParserRuleContext {
	public constructor(
		parent: antlr.ParserRuleContext | null,
		invokingState: number,
	) {
		super(parent, invokingState);
	}
	public ID(): antlr.TerminalNode[];
	public ID(i: number): antlr.TerminalNode | null;
	public ID(i?: number): antlr.TerminalNode | null | antlr.TerminalNode[] {
		if (i === undefined) {
			return this.getTokens(PostgreSQLDDLParser.ID);
		} else {
			return this.getToken(PostgreSQLDDLParser.ID, i);
		}
	}
	public override get ruleIndex(): number {
		return PostgreSQLDDLParser.RULE_columnConstraint;
	}
	public override enterRule(listener: PostgreSQLDDLListener): void {
		if (listener.enterColumnConstraint) {
			listener.enterColumnConstraint(this);
		}
	}
	public override exitRule(listener: PostgreSQLDDLListener): void {
		if (listener.exitColumnConstraint) {
			listener.exitColumnConstraint(this);
		}
	}
	public override accept<Result>(
		visitor: PostgreSQLDDLVisitor<Result>,
	): Result | null {
		if (visitor.visitColumnConstraint) {
			return visitor.visitColumnConstraint(this);
		} else {
			return visitor.visitChildren(this);
		}
	}
}
