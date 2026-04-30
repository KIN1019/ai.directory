// Generated from /Users/yatfuchan/Projects/ha/postgres-ddl-parser/src/syntax/PostgreSQLDDL.g4 by ANTLR 4.13.1

import * as antlr from "antlr4ng";
import { Token } from "antlr4ng";

export class PostgreSQLDDLLexer extends antlr.Lexer {
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

	public static readonly channelNames = ["DEFAULT_TOKEN_CHANNEL", "HIDDEN"];

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

	public static readonly modeNames = ["DEFAULT_MODE"];

	public static readonly ruleNames = [
		"T__0",
		"T__1",
		"T__2",
		"T__3",
		"T__4",
		"T__5",
		"T__6",
		"CREATE",
		"TABLE",
		"ID",
		"ID_",
		"NUMBER",
		"DIGIT",
		"WS",
		"COMMENT",
		"MULTILINE_COMMENT",
	];

	public constructor(input: antlr.CharStream) {
		super(input);
		this.interpreter = new antlr.LexerATNSimulator(
			this,
			PostgreSQLDDLLexer._ATN,
			PostgreSQLDDLLexer.decisionsToDFA,
			new antlr.PredictionContextCache(),
		);
	}

	public get grammarFileName(): string {
		return "PostgreSQLDDL.g4";
	}

	public get literalNames(): (string | null)[] {
		return PostgreSQLDDLLexer.literalNames;
	}
	public get symbolicNames(): (string | null)[] {
		return PostgreSQLDDLLexer.symbolicNames;
	}
	public get ruleNames(): string[] {
		return PostgreSQLDDLLexer.ruleNames;
	}

	public get serializedATN(): number[] {
		return PostgreSQLDDLLexer._serializedATN;
	}

	public get channelNames(): string[] {
		return PostgreSQLDDLLexer.channelNames;
	}

	public get modeNames(): string[] {
		return PostgreSQLDDLLexer.modeNames;
	}

	public static readonly _serializedATN: number[] = [
		4, 0, 15, 123, 6, -1, 2, 0, 7, 0, 2, 1, 7, 1, 2, 2, 7, 2, 2, 3, 7, 3, 2, 4,
		7, 4, 2, 5, 7, 5, 2, 6, 7, 6, 2, 7, 7, 7, 2, 8, 7, 8, 2, 9, 7, 9, 2, 10, 7,
		10, 2, 11, 7, 11, 2, 12, 7, 12, 2, 13, 7, 13, 2, 14, 7, 14, 2, 15, 7, 15, 1,
		0, 1, 0, 1, 1, 1, 1, 1, 2, 1, 2, 1, 3, 1, 3, 1, 4, 1, 4, 1, 5, 1, 5, 1, 6,
		1, 6, 1, 7, 1, 7, 1, 7, 1, 7, 1, 7, 1, 7, 1, 7, 1, 8, 1, 8, 1, 8, 1, 8, 1,
		8, 1, 8, 1, 9, 1, 9, 1, 9, 1, 9, 1, 9, 3, 9, 66, 8, 9, 1, 10, 1, 10, 5, 10,
		70, 8, 10, 10, 10, 12, 10, 73, 9, 10, 1, 11, 4, 11, 76, 8, 11, 11, 11, 12,
		11, 77, 1, 11, 1, 11, 4, 11, 82, 8, 11, 11, 11, 12, 11, 83, 3, 11, 86, 8,
		11, 1, 12, 1, 12, 1, 13, 4, 13, 91, 8, 13, 11, 13, 12, 13, 92, 1, 13, 1, 13,
		1, 14, 1, 14, 1, 14, 1, 14, 5, 14, 101, 8, 14, 10, 14, 12, 14, 104, 9, 14,
		1, 14, 1, 14, 1, 14, 1, 14, 1, 15, 1, 15, 1, 15, 1, 15, 5, 15, 114, 8, 15,
		10, 15, 12, 15, 117, 9, 15, 1, 15, 1, 15, 1, 15, 1, 15, 1, 15, 2, 102, 115,
		0, 16, 1, 1, 3, 2, 5, 3, 7, 4, 9, 5, 11, 6, 13, 7, 15, 8, 17, 9, 19, 10, 21,
		11, 23, 12, 25, 0, 27, 13, 29, 14, 31, 15, 1, 0, 11, 2, 0, 67, 67, 99, 99,
		2, 0, 82, 82, 114, 114, 2, 0, 69, 69, 101, 101, 2, 0, 65, 65, 97, 97, 2, 0,
		84, 84, 116, 116, 2, 0, 66, 66, 98, 98, 2, 0, 76, 76, 108, 108, 2, 0, 65,
		90, 97, 122, 4, 0, 48, 57, 65, 90, 95, 95, 97, 122, 1, 0, 48, 57, 3, 0, 9,
		10, 13, 13, 32, 32, 129, 0, 1, 1, 0, 0, 0, 0, 3, 1, 0, 0, 0, 0, 5, 1, 0, 0,
		0, 0, 7, 1, 0, 0, 0, 0, 9, 1, 0, 0, 0, 0, 11, 1, 0, 0, 0, 0, 13, 1, 0, 0, 0,
		0, 15, 1, 0, 0, 0, 0, 17, 1, 0, 0, 0, 0, 19, 1, 0, 0, 0, 0, 21, 1, 0, 0, 0,
		0, 23, 1, 0, 0, 0, 0, 27, 1, 0, 0, 0, 0, 29, 1, 0, 0, 0, 0, 31, 1, 0, 0, 0,
		1, 33, 1, 0, 0, 0, 3, 35, 1, 0, 0, 0, 5, 37, 1, 0, 0, 0, 7, 39, 1, 0, 0, 0,
		9, 41, 1, 0, 0, 0, 11, 43, 1, 0, 0, 0, 13, 45, 1, 0, 0, 0, 15, 47, 1, 0, 0,
		0, 17, 54, 1, 0, 0, 0, 19, 65, 1, 0, 0, 0, 21, 67, 1, 0, 0, 0, 23, 75, 1, 0,
		0, 0, 25, 87, 1, 0, 0, 0, 27, 90, 1, 0, 0, 0, 29, 96, 1, 0, 0, 0, 31, 109,
		1, 0, 0, 0, 33, 34, 5, 40, 0, 0, 34, 2, 1, 0, 0, 0, 35, 36, 5, 41, 0, 0, 36,
		4, 1, 0, 0, 0, 37, 38, 5, 59, 0, 0, 38, 6, 1, 0, 0, 0, 39, 40, 5, 44, 0, 0,
		40, 8, 1, 0, 0, 0, 41, 42, 5, 34, 0, 0, 42, 10, 1, 0, 0, 0, 43, 44, 5, 39,
		0, 0, 44, 12, 1, 0, 0, 0, 45, 46, 5, 58, 0, 0, 46, 14, 1, 0, 0, 0, 47, 48,
		7, 0, 0, 0, 48, 49, 7, 1, 0, 0, 49, 50, 7, 2, 0, 0, 50, 51, 7, 3, 0, 0, 51,
		52, 7, 4, 0, 0, 52, 53, 7, 2, 0, 0, 53, 16, 1, 0, 0, 0, 54, 55, 7, 4, 0, 0,
		55, 56, 7, 3, 0, 0, 56, 57, 7, 5, 0, 0, 57, 58, 7, 6, 0, 0, 58, 59, 7, 2, 0,
		0, 59, 18, 1, 0, 0, 0, 60, 61, 5, 34, 0, 0, 61, 62, 3, 21, 10, 0, 62, 63, 5,
		34, 0, 0, 63, 66, 1, 0, 0, 0, 64, 66, 3, 21, 10, 0, 65, 60, 1, 0, 0, 0, 65,
		64, 1, 0, 0, 0, 66, 20, 1, 0, 0, 0, 67, 71, 7, 7, 0, 0, 68, 70, 7, 8, 0, 0,
		69, 68, 1, 0, 0, 0, 70, 73, 1, 0, 0, 0, 71, 69, 1, 0, 0, 0, 71, 72, 1, 0, 0,
		0, 72, 22, 1, 0, 0, 0, 73, 71, 1, 0, 0, 0, 74, 76, 3, 25, 12, 0, 75, 74, 1,
		0, 0, 0, 76, 77, 1, 0, 0, 0, 77, 75, 1, 0, 0, 0, 77, 78, 1, 0, 0, 0, 78, 85,
		1, 0, 0, 0, 79, 81, 5, 46, 0, 0, 80, 82, 3, 25, 12, 0, 81, 80, 1, 0, 0, 0,
		82, 83, 1, 0, 0, 0, 83, 81, 1, 0, 0, 0, 83, 84, 1, 0, 0, 0, 84, 86, 1, 0, 0,
		0, 85, 79, 1, 0, 0, 0, 85, 86, 1, 0, 0, 0, 86, 24, 1, 0, 0, 0, 87, 88, 7, 9,
		0, 0, 88, 26, 1, 0, 0, 0, 89, 91, 7, 10, 0, 0, 90, 89, 1, 0, 0, 0, 91, 92,
		1, 0, 0, 0, 92, 90, 1, 0, 0, 0, 92, 93, 1, 0, 0, 0, 93, 94, 1, 0, 0, 0, 94,
		95, 6, 13, 0, 0, 95, 28, 1, 0, 0, 0, 96, 97, 5, 45, 0, 0, 97, 98, 5, 45, 0,
		0, 98, 102, 1, 0, 0, 0, 99, 101, 9, 0, 0, 0, 100, 99, 1, 0, 0, 0, 101, 104,
		1, 0, 0, 0, 102, 103, 1, 0, 0, 0, 102, 100, 1, 0, 0, 0, 103, 105, 1, 0, 0,
		0, 104, 102, 1, 0, 0, 0, 105, 106, 5, 10, 0, 0, 106, 107, 1, 0, 0, 0, 107,
		108, 6, 14, 0, 0, 108, 30, 1, 0, 0, 0, 109, 110, 5, 47, 0, 0, 110, 111, 5,
		42, 0, 0, 111, 115, 1, 0, 0, 0, 112, 114, 9, 0, 0, 0, 113, 112, 1, 0, 0, 0,
		114, 117, 1, 0, 0, 0, 115, 116, 1, 0, 0, 0, 115, 113, 1, 0, 0, 0, 116, 118,
		1, 0, 0, 0, 117, 115, 1, 0, 0, 0, 118, 119, 5, 42, 0, 0, 119, 120, 5, 47, 0,
		0, 120, 121, 1, 0, 0, 0, 121, 122, 6, 15, 0, 0, 122, 32, 1, 0, 0, 0, 9, 0,
		65, 71, 77, 83, 85, 92, 102, 115, 1, 6, 0, 0,
	];

	private static __ATN: antlr.ATN;
	public static get _ATN(): antlr.ATN {
		if (!PostgreSQLDDLLexer.__ATN) {
			PostgreSQLDDLLexer.__ATN = new antlr.ATNDeserializer().deserialize(
				PostgreSQLDDLLexer._serializedATN,
			);
		}

		return PostgreSQLDDLLexer.__ATN;
	}

	private static readonly vocabulary = new antlr.Vocabulary(
		PostgreSQLDDLLexer.literalNames,
		PostgreSQLDDLLexer.symbolicNames,
		[],
	);

	public override get vocabulary(): antlr.Vocabulary {
		return PostgreSQLDDLLexer.vocabulary;
	}

	private static readonly decisionsToDFA =
		PostgreSQLDDLLexer._ATN.decisionToState.map(
			(ds: antlr.DecisionState, index: number) => new antlr.DFA(ds, index),
		);
}
