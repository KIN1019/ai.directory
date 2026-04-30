// Generated from /Users/yatfuchan/Projects/ha/postgres-ddl-parser/src/newsyntax/Weighting.g4 by ANTLR 4.13.1

import * as antlr from "antlr4ng";
import { Token } from "antlr4ng";

export class WeightingLexer extends antlr.Lexer {
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

	public static readonly channelNames = ["DEFAULT_TOKEN_CHANNEL", "HIDDEN"];

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

	public static readonly modeNames = ["DEFAULT_MODE"];

	public static readonly ruleNames = [
		"T__0",
		"T__1",
		"T__2",
		"T__3",
		"T__4",
		"T__5",
		"T__6",
		"T__7",
		"T__8",
		"T__9",
		"COMMA",
		"WS",
		"ID",
		"NUMBER",
		"DIGIT",
	];

	public constructor(input: antlr.CharStream) {
		super(input);
		this.interpreter = new antlr.LexerATNSimulator(
			this,
			WeightingLexer._ATN,
			WeightingLexer.decisionsToDFA,
			new antlr.PredictionContextCache(),
		);
	}

	public get grammarFileName(): string {
		return "Weighting.g4";
	}

	public get literalNames(): (string | null)[] {
		return WeightingLexer.literalNames;
	}
	public get symbolicNames(): (string | null)[] {
		return WeightingLexer.symbolicNames;
	}
	public get ruleNames(): string[] {
		return WeightingLexer.ruleNames;
	}

	public get serializedATN(): number[] {
		return WeightingLexer._serializedATN;
	}

	public get channelNames(): string[] {
		return WeightingLexer.channelNames;
	}

	public get modeNames(): string[] {
		return WeightingLexer.modeNames;
	}

	public static readonly _serializedATN: number[] = [
		4, 0, 14, 86, 6, -1, 2, 0, 7, 0, 2, 1, 7, 1, 2, 2, 7, 2, 2, 3, 7, 3, 2, 4,
		7, 4, 2, 5, 7, 5, 2, 6, 7, 6, 2, 7, 7, 7, 2, 8, 7, 8, 2, 9, 7, 9, 2, 10, 7,
		10, 2, 11, 7, 11, 2, 12, 7, 12, 2, 13, 7, 13, 2, 14, 7, 14, 1, 0, 1, 0, 1,
		1, 1, 1, 1, 2, 1, 2, 1, 3, 1, 3, 1, 4, 1, 4, 1, 5, 1, 5, 1, 6, 1, 6, 1, 7,
		1, 7, 1, 8, 1, 8, 1, 9, 1, 9, 1, 9, 1, 10, 1, 10, 1, 11, 4, 11, 56, 8, 11,
		11, 11, 12, 11, 57, 1, 11, 1, 11, 1, 12, 1, 12, 5, 12, 64, 8, 12, 10, 12,
		12, 12, 67, 9, 12, 1, 12, 3, 12, 70, 8, 12, 1, 13, 4, 13, 73, 8, 13, 11, 13,
		12, 13, 74, 1, 13, 1, 13, 4, 13, 79, 8, 13, 11, 13, 12, 13, 80, 3, 13, 83,
		8, 13, 1, 14, 1, 14, 0, 0, 15, 1, 1, 3, 2, 5, 3, 7, 4, 9, 5, 11, 6, 13, 7,
		15, 8, 17, 9, 19, 10, 21, 11, 23, 12, 25, 13, 27, 14, 29, 0, 1, 0, 4, 2, 0,
		9, 9, 32, 32, 2, 0, 65, 90, 97, 122, 6, 0, 38, 38, 45, 45, 48, 58, 65, 90,
		95, 95, 97, 122, 1, 0, 48, 57, 90, 0, 1, 1, 0, 0, 0, 0, 3, 1, 0, 0, 0, 0, 5,
		1, 0, 0, 0, 0, 7, 1, 0, 0, 0, 0, 9, 1, 0, 0, 0, 0, 11, 1, 0, 0, 0, 0, 13, 1,
		0, 0, 0, 0, 15, 1, 0, 0, 0, 0, 17, 1, 0, 0, 0, 0, 19, 1, 0, 0, 0, 0, 21, 1,
		0, 0, 0, 0, 23, 1, 0, 0, 0, 0, 25, 1, 0, 0, 0, 0, 27, 1, 0, 0, 0, 1, 31, 1,
		0, 0, 0, 3, 33, 1, 0, 0, 0, 5, 35, 1, 0, 0, 0, 7, 37, 1, 0, 0, 0, 9, 39, 1,
		0, 0, 0, 11, 41, 1, 0, 0, 0, 13, 43, 1, 0, 0, 0, 15, 45, 1, 0, 0, 0, 17, 47,
		1, 0, 0, 0, 19, 49, 1, 0, 0, 0, 21, 52, 1, 0, 0, 0, 23, 55, 1, 0, 0, 0, 25,
		69, 1, 0, 0, 0, 27, 72, 1, 0, 0, 0, 29, 84, 1, 0, 0, 0, 31, 32, 5, 123, 0,
		0, 32, 2, 1, 0, 0, 0, 33, 34, 5, 125, 0, 0, 34, 4, 1, 0, 0, 0, 35, 36, 5,
		61, 0, 0, 36, 6, 1, 0, 0, 0, 37, 38, 5, 91, 0, 0, 38, 8, 1, 0, 0, 0, 39, 40,
		5, 93, 0, 0, 40, 10, 1, 0, 0, 0, 41, 42, 5, 47, 0, 0, 42, 12, 1, 0, 0, 0,
		43, 44, 5, 120, 0, 0, 44, 14, 1, 0, 0, 0, 45, 46, 5, 40, 0, 0, 46, 16, 1, 0,
		0, 0, 47, 48, 5, 41, 0, 0, 48, 18, 1, 0, 0, 0, 49, 50, 5, 60, 0, 0, 50, 51,
		5, 61, 0, 0, 51, 20, 1, 0, 0, 0, 52, 53, 5, 44, 0, 0, 53, 22, 1, 0, 0, 0,
		54, 56, 7, 0, 0, 0, 55, 54, 1, 0, 0, 0, 56, 57, 1, 0, 0, 0, 57, 55, 1, 0, 0,
		0, 57, 58, 1, 0, 0, 0, 58, 59, 1, 0, 0, 0, 59, 60, 6, 11, 0, 0, 60, 24, 1,
		0, 0, 0, 61, 65, 7, 1, 0, 0, 62, 64, 7, 2, 0, 0, 63, 62, 1, 0, 0, 0, 64, 67,
		1, 0, 0, 0, 65, 63, 1, 0, 0, 0, 65, 66, 1, 0, 0, 0, 66, 70, 1, 0, 0, 0, 67,
		65, 1, 0, 0, 0, 68, 70, 5, 42, 0, 0, 69, 61, 1, 0, 0, 0, 69, 68, 1, 0, 0, 0,
		70, 26, 1, 0, 0, 0, 71, 73, 3, 29, 14, 0, 72, 71, 1, 0, 0, 0, 73, 74, 1, 0,
		0, 0, 74, 72, 1, 0, 0, 0, 74, 75, 1, 0, 0, 0, 75, 82, 1, 0, 0, 0, 76, 78, 5,
		46, 0, 0, 77, 79, 3, 29, 14, 0, 78, 77, 1, 0, 0, 0, 79, 80, 1, 0, 0, 0, 80,
		78, 1, 0, 0, 0, 80, 81, 1, 0, 0, 0, 81, 83, 1, 0, 0, 0, 82, 76, 1, 0, 0, 0,
		82, 83, 1, 0, 0, 0, 83, 28, 1, 0, 0, 0, 84, 85, 7, 3, 0, 0, 85, 30, 1, 0, 0,
		0, 7, 0, 57, 65, 69, 74, 80, 82, 1, 6, 0, 0,
	];

	private static __ATN: antlr.ATN;
	public static get _ATN(): antlr.ATN {
		if (!WeightingLexer.__ATN) {
			WeightingLexer.__ATN = new antlr.ATNDeserializer().deserialize(
				WeightingLexer._serializedATN,
			);
		}

		return WeightingLexer.__ATN;
	}

	private static readonly vocabulary = new antlr.Vocabulary(
		WeightingLexer.literalNames,
		WeightingLexer.symbolicNames,
		[],
	);

	public override get vocabulary(): antlr.Vocabulary {
		return WeightingLexer.vocabulary;
	}

	private static readonly decisionsToDFA =
		WeightingLexer._ATN.decisionToState.map(
			(ds: antlr.DecisionState, index: number) => new antlr.DFA(ds, index),
		);
}
