grammar PostgreSQLDDL;

file: (createTable | .)*? EOF;
createTable:
	CREATE ID* TABLE ID* tableName '(' tableColumns ')' ';';
tableName: ID;
tableColumns: tableColumn (',' tableColumn)*;
tableColumn: columnName dataType ID*;
columnName: ID | '"' ID '"' | '\'' ID '\'' | ID ':' typecast;
typecast: ID;
dataType: ID ('(' NUMBER (',' NUMBER)* ')')?;
columnConstraint: ID*;

CREATE: [Cc][Rr][Ee][Aa][Tt][Ee];
TABLE: [Tt][Aa][Bb][Ll][Ee];
ID: '"' ID_ '"' | ID_;
ID_: [a-zA-Z][a-zA-Z0-9_]*;
NUMBER: DIGIT+ ('.' DIGIT+)?;
fragment DIGIT: [0-9];
WS: [ \t\r\n]+ -> skip;
COMMENT: '--' .*? '\n' -> skip;
MULTILINE_COMMENT: '/*' .*? '*/' -> skip;