// Generated from /Users/yatfuchan/Projects/ha/postgres-ddl-parser/src/newsyntax/Weighting.g4 by ANTLR 4.13.1

import * as antlr from "antlr4ng";
import { Token } from "antlr4ng";

import { WeightingVisitor } from "./WeightingVisitor.js";

// for running tests with parameters, TODO: discuss strategy for typed parameters in CI
// eslint-disable-next-line no-unused-vars
type int = number;

export class WeightingParser extends antlr.Parser {
	public static readonly T__0 = 1;
	public static readonly T__1 = 2;
	public static readonly T__2 = 3;
	public static readonly T__3 = 4;
	public static readonly T__4 = 5;
	public static readonly T__5 = 6;
	public static readonly T__6 = 7;
	public static readonly T__7 = 8;
	public static readonly T__8 = 9;
	public static readonly T__9 = 10;
	public static readonly COMMA = 11;
	public static readonly WS = 12;
	public static readonly ID = 13;
	public static readonly NUMBER = 14;
	public static readonly RULE_expr = 0;
	public static readonly RULE_directive = 1;
	public static readonly RULE_directiveItem = 2;
	public static readonly RULE_flagDirective = 3;
	public static readonly RULE_valueDirective = 4;
	public static readonly RULE_weightingGroup = 5;
	public static readonly RULE_groupSubjects = 6;
	public static readonly RULE_simpleSubject = 7;
	public static readonly RULE_alternativeSubject = 8;

	public static readonly literalNames = [
		null,
		"'{'",
		"'}'",
		"'='",
		"'['",
		"']'",
		"'/'",
		"'x'",
		"'('",
		"')'",
		"'<='",
		"','",
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
		null,
		null,
		null,
		"COMMA",
		"WS",
		"ID",
		"NUMBER",
	];
	public static readonly ruleNames = [
		"expr",
		"directive",
		"directiveItem",
		"flagDirective",
		"valueDirective",
		"weightingGroup",
		"groupSubjects",
		"simpleSubject",
		"alternativeSubject",
	];

	public get grammarFileName(): string {
		return "Weighting.g4";
	}
	public get literalNames(): (string | null)[] {
		return WeightingParser.literalNames;
	}
	public get symbolicNames(): (string | null)[] {
		return WeightingParser.symbolicNames;
	}
	public get ruleNames(): string[] {
		return WeightingParser.ruleNames;
	}
	public get serializedATN(): number[] {
		return WeightingParser._serializedATN;
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
			WeightingParser._ATN,
			WeightingParser.decisionsToDFA,
			new antlr.PredictionContextCache(),
		);
	}
	public expr(): ExprContext {
		let localContext = new ExprContext(this.context, this.state);
		this.enterRule(localContext, 0, WeightingParser.RULE_expr);
		let _la: number;
		try {
			this.enterOuterAlt(localContext, 1);
			{
				this.state = 19;
				this.errorHandler.sync(this);
				_la = this.tokenStream.LA(1);
				if (_la === 1) {
					{
						this.state = 18;
						this.directive();
					}
				}

				this.state = 26;
				this.errorHandler.sync(this);
				_la = this.tokenStream.LA(1);
				if (_la === 4) {
					{
						this.state = 22;
						this.errorHandler.sync(this);
						_la = this.tokenStream.LA(1);
						do {
							{
								{
									this.state = 21;
									this.weightingGroup();
								}
							}
							this.state = 24;
							this.errorHandler.sync(this);
							_la = this.tokenStream.LA(1);
						} while (_la === 4);
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
	public directive(): DirectiveContext {
		let localContext = new DirectiveContext(this.context, this.state);
		this.enterRule(localContext, 2, WeightingParser.RULE_directive);
		let _la: number;
		try {
			this.enterOuterAlt(localContext, 1);
			{
				this.state = 28;
				this.match(WeightingParser.T__0);
				this.state = 29;
				this.directiveItem();
				this.state = 34;
				this.errorHandler.sync(this);
				_la = this.tokenStream.LA(1);
				while (_la === 11) {
					{
						{
							this.state = 30;
							this.match(WeightingParser.COMMA);
							this.state = 31;
							this.directiveItem();
						}
					}
					this.state = 36;
					this.errorHandler.sync(this);
					_la = this.tokenStream.LA(1);
				}
				this.state = 37;
				this.match(WeightingParser.T__1);
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
	public directiveItem(): DirectiveItemContext {
		let localContext = new DirectiveItemContext(this.context, this.state);
		this.enterRule(localContext, 4, WeightingParser.RULE_directiveItem);
		try {
			this.state = 41;
			this.errorHandler.sync(this);
			switch (
				this.interpreter.adaptivePredict(this.tokenStream, 4, this.context)
			) {
				case 1:
					this.enterOuterAlt(localContext, 1);
					{
						this.state = 39;
						this.flagDirective();
					}
					break;
				case 2:
					this.enterOuterAlt(localContext, 2);
					{
						this.state = 40;
						this.valueDirective();
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
	public flagDirective(): FlagDirectiveContext {
		let localContext = new FlagDirectiveContext(this.context, this.state);
		this.enterRule(localContext, 6, WeightingParser.RULE_flagDirective);
		try {
			this.enterOuterAlt(localContext, 1);
			{
				this.state = 43;
				this.match(WeightingParser.ID);
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
	public valueDirective(): ValueDirectiveContext {
		let localContext = new ValueDirectiveContext(this.context, this.state);
		this.enterRule(localContext, 8, WeightingParser.RULE_valueDirective);
		try {
			this.enterOuterAlt(localContext, 1);
			{
				this.state = 45;
				this.match(WeightingParser.ID);
				this.state = 46;
				this.match(WeightingParser.T__2);
				this.state = 47;
				this.match(WeightingParser.NUMBER);
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
	public weightingGroup(): WeightingGroupContext {
		let localContext = new WeightingGroupContext(this.context, this.state);
		this.enterRule(localContext, 10, WeightingParser.RULE_weightingGroup);
		try {
			this.enterOuterAlt(localContext, 1);
			{
				this.state = 49;
				this.match(WeightingParser.T__3);
				this.state = 50;
				this.match(WeightingParser.NUMBER);
				this.state = 51;
				this.match(WeightingParser.T__4);
				this.state = 52;
				this.groupSubjects();
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
	public groupSubjects(): GroupSubjectsContext {
		let localContext = new GroupSubjectsContext(this.context, this.state);
		this.enterRule(localContext, 12, WeightingParser.RULE_groupSubjects);
		let _la: number;
		try {
			this.enterOuterAlt(localContext, 1);
			{
				this.state = 56;
				this.errorHandler.sync(this);
				switch (
					this.interpreter.adaptivePredict(this.tokenStream, 5, this.context)
				) {
					case 1:
						{
							this.state = 54;
							this.simpleSubject();
						}
						break;
					case 2:
						{
							this.state = 55;
							this.alternativeSubject();
						}
						break;
				}
				this.state = 65;
				this.errorHandler.sync(this);
				_la = this.tokenStream.LA(1);
				while (_la === 11) {
					{
						{
							this.state = 58;
							this.match(WeightingParser.COMMA);
							this.state = 61;
							this.errorHandler.sync(this);
							switch (
								this.interpreter.adaptivePredict(
									this.tokenStream,
									6,
									this.context,
								)
							) {
								case 1:
									{
										this.state = 59;
										this.simpleSubject();
									}
									break;
								case 2:
									{
										this.state = 60;
										this.alternativeSubject();
									}
									break;
							}
						}
					}
					this.state = 67;
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
	public simpleSubject(): SimpleSubjectContext {
		let localContext = new SimpleSubjectContext(this.context, this.state);
		this.enterRule(localContext, 14, WeightingParser.RULE_simpleSubject);
		try {
			this.enterOuterAlt(localContext, 1);
			{
				this.state = 68;
				this.match(WeightingParser.ID);
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
	public alternativeSubject(): AlternativeSubjectContext {
		let localContext = new AlternativeSubjectContext(this.context, this.state);
		this.enterRule(localContext, 16, WeightingParser.RULE_alternativeSubject);
		let _la: number;
		try {
			this.state = 105;
			this.errorHandler.sync(this);
			switch (this.tokenStream.LA(1)) {
				case WeightingParser.ID:
					localContext = new AltNoCountContext(localContext);
					this.enterOuterAlt(localContext, 1);
					{
						this.state = 70;
						this.simpleSubject();
						this.state = 75;
						this.errorHandler.sync(this);
						_la = this.tokenStream.LA(1);
						while (_la === 6) {
							{
								{
									this.state = 71;
									this.match(WeightingParser.T__5);
									this.state = 72;
									this.simpleSubject();
								}
							}
							this.state = 77;
							this.errorHandler.sync(this);
							_la = this.tokenStream.LA(1);
						}
					}
					break;
				case WeightingParser.NUMBER:
					localContext = new AltMinCountContext(localContext);
					this.enterOuterAlt(localContext, 2);
					{
						this.state = 78;
						this.match(WeightingParser.NUMBER);
						this.state = 79;
						this.match(WeightingParser.T__6);
						this.state = 80;
						this.match(WeightingParser.T__7);
						this.state = 81;
						this.simpleSubject();
						this.state = 86;
						this.errorHandler.sync(this);
						_la = this.tokenStream.LA(1);
						while (_la === 6) {
							{
								{
									this.state = 82;
									this.match(WeightingParser.T__5);
									this.state = 83;
									this.simpleSubject();
								}
							}
							this.state = 88;
							this.errorHandler.sync(this);
							_la = this.tokenStream.LA(1);
						}
						this.state = 89;
						this.match(WeightingParser.T__8);
					}
					break;
				case WeightingParser.T__9:
					localContext = new AltMaxCountContext(localContext);
					this.enterOuterAlt(localContext, 3);
					{
						this.state = 91;
						this.match(WeightingParser.T__9);
						this.state = 92;
						this.match(WeightingParser.NUMBER);
						this.state = 93;
						this.match(WeightingParser.T__6);
						this.state = 94;
						this.match(WeightingParser.T__7);
						this.state = 95;
						this.simpleSubject();
						this.state = 100;
						this.errorHandler.sync(this);
						_la = this.tokenStream.LA(1);
						while (_la === 6) {
							{
								{
									this.state = 96;
									this.match(WeightingParser.T__5);
									this.state = 97;
									this.simpleSubject();
								}
							}
							this.state = 102;
							this.errorHandler.sync(this);
							_la = this.tokenStream.LA(1);
						}
						this.state = 103;
						this.match(WeightingParser.T__8);
					}
					break;
				default:
					throw new antlr.NoViableAltException(this);
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
		4, 1, 14, 108, 2, 0, 7, 0, 2, 1, 7, 1, 2, 2, 7, 2, 2, 3, 7, 3, 2, 4, 7, 4,
		2, 5, 7, 5, 2, 6, 7, 6, 2, 7, 7, 7, 2, 8, 7, 8, 1, 0, 3, 0, 20, 8, 0, 1, 0,
		4, 0, 23, 8, 0, 11, 0, 12, 0, 24, 3, 0, 27, 8, 0, 1, 1, 1, 1, 1, 1, 1, 1, 5,
		1, 33, 8, 1, 10, 1, 12, 1, 36, 9, 1, 1, 1, 1, 1, 1, 2, 1, 2, 3, 2, 42, 8, 2,
		1, 3, 1, 3, 1, 4, 1, 4, 1, 4, 1, 4, 1, 5, 1, 5, 1, 5, 1, 5, 1, 5, 1, 6, 1,
		6, 3, 6, 57, 8, 6, 1, 6, 1, 6, 1, 6, 3, 6, 62, 8, 6, 5, 6, 64, 8, 6, 10, 6,
		12, 6, 67, 9, 6, 1, 7, 1, 7, 1, 8, 1, 8, 1, 8, 5, 8, 74, 8, 8, 10, 8, 12, 8,
		77, 9, 8, 1, 8, 1, 8, 1, 8, 1, 8, 1, 8, 1, 8, 5, 8, 85, 8, 8, 10, 8, 12, 8,
		88, 9, 8, 1, 8, 1, 8, 1, 8, 1, 8, 1, 8, 1, 8, 1, 8, 1, 8, 1, 8, 5, 8, 99, 8,
		8, 10, 8, 12, 8, 102, 9, 8, 1, 8, 1, 8, 3, 8, 106, 8, 8, 1, 8, 0, 0, 9, 0,
		2, 4, 6, 8, 10, 12, 14, 16, 0, 0, 111, 0, 19, 1, 0, 0, 0, 2, 28, 1, 0, 0, 0,
		4, 41, 1, 0, 0, 0, 6, 43, 1, 0, 0, 0, 8, 45, 1, 0, 0, 0, 10, 49, 1, 0, 0, 0,
		12, 56, 1, 0, 0, 0, 14, 68, 1, 0, 0, 0, 16, 105, 1, 0, 0, 0, 18, 20, 3, 2,
		1, 0, 19, 18, 1, 0, 0, 0, 19, 20, 1, 0, 0, 0, 20, 26, 1, 0, 0, 0, 21, 23, 3,
		10, 5, 0, 22, 21, 1, 0, 0, 0, 23, 24, 1, 0, 0, 0, 24, 22, 1, 0, 0, 0, 24,
		25, 1, 0, 0, 0, 25, 27, 1, 0, 0, 0, 26, 22, 1, 0, 0, 0, 26, 27, 1, 0, 0, 0,
		27, 1, 1, 0, 0, 0, 28, 29, 5, 1, 0, 0, 29, 34, 3, 4, 2, 0, 30, 31, 5, 11, 0,
		0, 31, 33, 3, 4, 2, 0, 32, 30, 1, 0, 0, 0, 33, 36, 1, 0, 0, 0, 34, 32, 1, 0,
		0, 0, 34, 35, 1, 0, 0, 0, 35, 37, 1, 0, 0, 0, 36, 34, 1, 0, 0, 0, 37, 38, 5,
		2, 0, 0, 38, 3, 1, 0, 0, 0, 39, 42, 3, 6, 3, 0, 40, 42, 3, 8, 4, 0, 41, 39,
		1, 0, 0, 0, 41, 40, 1, 0, 0, 0, 42, 5, 1, 0, 0, 0, 43, 44, 5, 13, 0, 0, 44,
		7, 1, 0, 0, 0, 45, 46, 5, 13, 0, 0, 46, 47, 5, 3, 0, 0, 47, 48, 5, 14, 0, 0,
		48, 9, 1, 0, 0, 0, 49, 50, 5, 4, 0, 0, 50, 51, 5, 14, 0, 0, 51, 52, 5, 5, 0,
		0, 52, 53, 3, 12, 6, 0, 53, 11, 1, 0, 0, 0, 54, 57, 3, 14, 7, 0, 55, 57, 3,
		16, 8, 0, 56, 54, 1, 0, 0, 0, 56, 55, 1, 0, 0, 0, 57, 65, 1, 0, 0, 0, 58,
		61, 5, 11, 0, 0, 59, 62, 3, 14, 7, 0, 60, 62, 3, 16, 8, 0, 61, 59, 1, 0, 0,
		0, 61, 60, 1, 0, 0, 0, 62, 64, 1, 0, 0, 0, 63, 58, 1, 0, 0, 0, 64, 67, 1, 0,
		0, 0, 65, 63, 1, 0, 0, 0, 65, 66, 1, 0, 0, 0, 66, 13, 1, 0, 0, 0, 67, 65, 1,
		0, 0, 0, 68, 69, 5, 13, 0, 0, 69, 15, 1, 0, 0, 0, 70, 75, 3, 14, 7, 0, 71,
		72, 5, 6, 0, 0, 72, 74, 3, 14, 7, 0, 73, 71, 1, 0, 0, 0, 74, 77, 1, 0, 0, 0,
		75, 73, 1, 0, 0, 0, 75, 76, 1, 0, 0, 0, 76, 106, 1, 0, 0, 0, 77, 75, 1, 0,
		0, 0, 78, 79, 5, 14, 0, 0, 79, 80, 5, 7, 0, 0, 80, 81, 5, 8, 0, 0, 81, 86,
		3, 14, 7, 0, 82, 83, 5, 6, 0, 0, 83, 85, 3, 14, 7, 0, 84, 82, 1, 0, 0, 0,
		85, 88, 1, 0, 0, 0, 86, 84, 1, 0, 0, 0, 86, 87, 1, 0, 0, 0, 87, 89, 1, 0, 0,
		0, 88, 86, 1, 0, 0, 0, 89, 90, 5, 9, 0, 0, 90, 106, 1, 0, 0, 0, 91, 92, 5,
		10, 0, 0, 92, 93, 5, 14, 0, 0, 93, 94, 5, 7, 0, 0, 94, 95, 5, 8, 0, 0, 95,
		100, 3, 14, 7, 0, 96, 97, 5, 6, 0, 0, 97, 99, 3, 14, 7, 0, 98, 96, 1, 0, 0,
		0, 99, 102, 1, 0, 0, 0, 100, 98, 1, 0, 0, 0, 100, 101, 1, 0, 0, 0, 101, 103,
		1, 0, 0, 0, 102, 100, 1, 0, 0, 0, 103, 104, 5, 9, 0, 0, 104, 106, 1, 0, 0,
		0, 105, 70, 1, 0, 0, 0, 105, 78, 1, 0, 0, 0, 105, 91, 1, 0, 0, 0, 106, 17,
		1, 0, 0, 0, 12, 19, 24, 26, 34, 41, 56, 61, 65, 75, 86, 100, 105,
	];

	private static __ATN: antlr.ATN;
	public static get _ATN(): antlr.ATN {
		if (!WeightingParser.__ATN) {
			WeightingParser.__ATN = new antlr.ATNDeserializer().deserialize(
				WeightingParser._serializedATN,
			);
		}

		return WeightingParser.__ATN;
	}

	private static readonly vocabulary = new antlr.Vocabulary(
		WeightingParser.literalNames,
		WeightingParser.symbolicNames,
		[],
	);

	public override get vocabulary(): antlr.Vocabulary {
		return WeightingParser.vocabulary;
	}

	private static readonly decisionsToDFA =
		WeightingParser._ATN.decisionToState.map(
			(ds: antlr.DecisionState, index: number) => new antlr.DFA(ds, index),
		);
}

export class ExprContext extends antlr.ParserRuleContext {
	public constructor(
		parent: antlr.ParserRuleContext | null,
		invokingState: number,
	) {
		super(parent, invokingState);
	}
	public directive(): DirectiveContext | null {
		return this.getRuleContext(0, DirectiveContext);
	}
	public weightingGroup(): WeightingGroupContext[];
	public weightingGroup(i: number): WeightingGroupContext | null;
	public weightingGroup(
		i?: number,
	): WeightingGroupContext[] | WeightingGroupContext | null {
		if (i === undefined) {
			return this.getRuleContexts(WeightingGroupContext);
		}

		return this.getRuleContext(i, WeightingGroupContext);
	}
	public override get ruleIndex(): number {
		return WeightingParser.RULE_expr;
	}
	public override accept<Result>(
		visitor: WeightingVisitor<Result>,
	): Result | null {
		if (visitor.visitExpr) {
			return visitor.visitExpr(this);
		} else {
			return visitor.visitChildren(this);
		}
	}
}

export class DirectiveContext extends antlr.ParserRuleContext {
	public constructor(
		parent: antlr.ParserRuleContext | null,
		invokingState: number,
	) {
		super(parent, invokingState);
	}
	public directiveItem(): DirectiveItemContext[];
	public directiveItem(i: number): DirectiveItemContext | null;
	public directiveItem(
		i?: number,
	): DirectiveItemContext[] | DirectiveItemContext | null {
		if (i === undefined) {
			return this.getRuleContexts(DirectiveItemContext);
		}

		return this.getRuleContext(i, DirectiveItemContext);
	}
	public COMMA(): antlr.TerminalNode[];
	public COMMA(i: number): antlr.TerminalNode | null;
	public COMMA(i?: number): antlr.TerminalNode | null | antlr.TerminalNode[] {
		if (i === undefined) {
			return this.getTokens(WeightingParser.COMMA);
		} else {
			return this.getToken(WeightingParser.COMMA, i);
		}
	}
	public override get ruleIndex(): number {
		return WeightingParser.RULE_directive;
	}
	public override accept<Result>(
		visitor: WeightingVisitor<Result>,
	): Result | null {
		if (visitor.visitDirective) {
			return visitor.visitDirective(this);
		} else {
			return visitor.visitChildren(this);
		}
	}
}

export class DirectiveItemContext extends antlr.ParserRuleContext {
	public constructor(
		parent: antlr.ParserRuleContext | null,
		invokingState: number,
	) {
		super(parent, invokingState);
	}
	public flagDirective(): FlagDirectiveContext | null {
		return this.getRuleContext(0, FlagDirectiveContext);
	}
	public valueDirective(): ValueDirectiveContext | null {
		return this.getRuleContext(0, ValueDirectiveContext);
	}
	public override get ruleIndex(): number {
		return WeightingParser.RULE_directiveItem;
	}
	public override accept<Result>(
		visitor: WeightingVisitor<Result>,
	): Result | null {
		if (visitor.visitDirectiveItem) {
			return visitor.visitDirectiveItem(this);
		} else {
			return visitor.visitChildren(this);
		}
	}
}

export class FlagDirectiveContext extends antlr.ParserRuleContext {
	public constructor(
		parent: antlr.ParserRuleContext | null,
		invokingState: number,
	) {
		super(parent, invokingState);
	}
	public ID(): antlr.TerminalNode {
		return this.getToken(WeightingParser.ID, 0)!;
	}
	public override get ruleIndex(): number {
		return WeightingParser.RULE_flagDirective;
	}
	public override accept<Result>(
		visitor: WeightingVisitor<Result>,
	): Result | null {
		if (visitor.visitFlagDirective) {
			return visitor.visitFlagDirective(this);
		} else {
			return visitor.visitChildren(this);
		}
	}
}

export class ValueDirectiveContext extends antlr.ParserRuleContext {
	public constructor(
		parent: antlr.ParserRuleContext | null,
		invokingState: number,
	) {
		super(parent, invokingState);
	}
	public ID(): antlr.TerminalNode {
		return this.getToken(WeightingParser.ID, 0)!;
	}
	public NUMBER(): antlr.TerminalNode {
		return this.getToken(WeightingParser.NUMBER, 0)!;
	}
	public override get ruleIndex(): number {
		return WeightingParser.RULE_valueDirective;
	}
	public override accept<Result>(
		visitor: WeightingVisitor<Result>,
	): Result | null {
		if (visitor.visitValueDirective) {
			return visitor.visitValueDirective(this);
		} else {
			return visitor.visitChildren(this);
		}
	}
}

export class WeightingGroupContext extends antlr.ParserRuleContext {
	public constructor(
		parent: antlr.ParserRuleContext | null,
		invokingState: number,
	) {
		super(parent, invokingState);
	}
	public NUMBER(): antlr.TerminalNode {
		return this.getToken(WeightingParser.NUMBER, 0)!;
	}
	public groupSubjects(): GroupSubjectsContext {
		return this.getRuleContext(0, GroupSubjectsContext)!;
	}
	public override get ruleIndex(): number {
		return WeightingParser.RULE_weightingGroup;
	}
	public override accept<Result>(
		visitor: WeightingVisitor<Result>,
	): Result | null {
		if (visitor.visitWeightingGroup) {
			return visitor.visitWeightingGroup(this);
		} else {
			return visitor.visitChildren(this);
		}
	}
}

export class GroupSubjectsContext extends antlr.ParserRuleContext {
	public constructor(
		parent: antlr.ParserRuleContext | null,
		invokingState: number,
	) {
		super(parent, invokingState);
	}
	public simpleSubject(): SimpleSubjectContext[];
	public simpleSubject(i: number): SimpleSubjectContext | null;
	public simpleSubject(
		i?: number,
	): SimpleSubjectContext[] | SimpleSubjectContext | null {
		if (i === undefined) {
			return this.getRuleContexts(SimpleSubjectContext);
		}

		return this.getRuleContext(i, SimpleSubjectContext);
	}
	public alternativeSubject(): AlternativeSubjectContext[];
	public alternativeSubject(i: number): AlternativeSubjectContext | null;
	public alternativeSubject(
		i?: number,
	): AlternativeSubjectContext[] | AlternativeSubjectContext | null {
		if (i === undefined) {
			return this.getRuleContexts(AlternativeSubjectContext);
		}

		return this.getRuleContext(i, AlternativeSubjectContext);
	}
	public COMMA(): antlr.TerminalNode[];
	public COMMA(i: number): antlr.TerminalNode | null;
	public COMMA(i?: number): antlr.TerminalNode | null | antlr.TerminalNode[] {
		if (i === undefined) {
			return this.getTokens(WeightingParser.COMMA);
		} else {
			return this.getToken(WeightingParser.COMMA, i);
		}
	}
	public override get ruleIndex(): number {
		return WeightingParser.RULE_groupSubjects;
	}
	public override accept<Result>(
		visitor: WeightingVisitor<Result>,
	): Result | null {
		if (visitor.visitGroupSubjects) {
			return visitor.visitGroupSubjects(this);
		} else {
			return visitor.visitChildren(this);
		}
	}
}

export class SimpleSubjectContext extends antlr.ParserRuleContext {
	public constructor(
		parent: antlr.ParserRuleContext | null,
		invokingState: number,
	) {
		super(parent, invokingState);
	}
	public ID(): antlr.TerminalNode {
		return this.getToken(WeightingParser.ID, 0)!;
	}
	public override get ruleIndex(): number {
		return WeightingParser.RULE_simpleSubject;
	}
	public override accept<Result>(
		visitor: WeightingVisitor<Result>,
	): Result | null {
		if (visitor.visitSimpleSubject) {
			return visitor.visitSimpleSubject(this);
		} else {
			return visitor.visitChildren(this);
		}
	}
}

export class AlternativeSubjectContext extends antlr.ParserRuleContext {
	public constructor(
		parent: antlr.ParserRuleContext | null,
		invokingState: number,
	) {
		super(parent, invokingState);
	}
	public override get ruleIndex(): number {
		return WeightingParser.RULE_alternativeSubject;
	}
	public override copyFrom(ctx: AlternativeSubjectContext): void {
		super.copyFrom(ctx);
	}
}
export class AltMaxCountContext extends AlternativeSubjectContext {
	public constructor(ctx: AlternativeSubjectContext) {
		super(ctx.parent, ctx.invokingState);
		super.copyFrom(ctx);
	}
	public NUMBER(): antlr.TerminalNode {
		return this.getToken(WeightingParser.NUMBER, 0)!;
	}
	public simpleSubject(): SimpleSubjectContext[];
	public simpleSubject(i: number): SimpleSubjectContext | null;
	public simpleSubject(
		i?: number,
	): SimpleSubjectContext[] | SimpleSubjectContext | null {
		if (i === undefined) {
			return this.getRuleContexts(SimpleSubjectContext);
		}

		return this.getRuleContext(i, SimpleSubjectContext);
	}
	public override accept<Result>(
		visitor: WeightingVisitor<Result>,
	): Result | null {
		if (visitor.visitAltMaxCount) {
			return visitor.visitAltMaxCount(this);
		} else {
			return visitor.visitChildren(this);
		}
	}
}
export class AltNoCountContext extends AlternativeSubjectContext {
	public constructor(ctx: AlternativeSubjectContext) {
		super(ctx.parent, ctx.invokingState);
		super.copyFrom(ctx);
	}
	public simpleSubject(): SimpleSubjectContext[];
	public simpleSubject(i: number): SimpleSubjectContext | null;
	public simpleSubject(
		i?: number,
	): SimpleSubjectContext[] | SimpleSubjectContext | null {
		if (i === undefined) {
			return this.getRuleContexts(SimpleSubjectContext);
		}

		return this.getRuleContext(i, SimpleSubjectContext);
	}
	public override accept<Result>(
		visitor: WeightingVisitor<Result>,
	): Result | null {
		if (visitor.visitAltNoCount) {
			return visitor.visitAltNoCount(this);
		} else {
			return visitor.visitChildren(this);
		}
	}
}
export class AltMinCountContext extends AlternativeSubjectContext {
	public constructor(ctx: AlternativeSubjectContext) {
		super(ctx.parent, ctx.invokingState);
		super.copyFrom(ctx);
	}
	public NUMBER(): antlr.TerminalNode {
		return this.getToken(WeightingParser.NUMBER, 0)!;
	}
	public simpleSubject(): SimpleSubjectContext[];
	public simpleSubject(i: number): SimpleSubjectContext | null;
	public simpleSubject(
		i?: number,
	): SimpleSubjectContext[] | SimpleSubjectContext | null {
		if (i === undefined) {
			return this.getRuleContexts(SimpleSubjectContext);
		}

		return this.getRuleContext(i, SimpleSubjectContext);
	}
	public override accept<Result>(
		visitor: WeightingVisitor<Result>,
	): Result | null {
		if (visitor.visitAltMinCount) {
			return visitor.visitAltMinCount(this);
		} else {
			return visitor.visitChildren(this);
		}
	}
}
