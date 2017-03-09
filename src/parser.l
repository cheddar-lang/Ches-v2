%{
    // Ches: Lexer
    // This tokenizes the cheddar language
%}

%{

    // Handles Bases
    //
    // Defines the follwing functions:
    //     base.bin(string) -> string
    //     base.oct(string) -> string
    //     base.hex(string) -> string
    // Which perform string base conversions in their respective bases
    var base = {
    };

%}

%{
    // String handling
    //
    // This handles strings and the
    // pending string will go here
    if (!('stringBuffer' in yy)) {
        yy.stringBuffer = "";
    }
%}

%options flex

%lex

%x MULTILINE_COMMENT

VARIABLE_HEAD [A-Za-z_$]
VARIABLE_TAIL [A-Za-z_$0-9]

%x DQ_STRING
%x SQ_STRING

%%

// Ignore the followings things because we don't like them
"//".*                                            ; // Single line comments

// Handles Multiline comments
("/*")                                            this.begin("MULTILINE_COMMENT");
<MULTILINE_COMMENT>(?:[^/*]|"*"[^/]|"/"[^*])+     ;
<MULTILINE_COMMENT>("*/")                         this.popState();

<INITIAL>["]                                      { this.begin("DQ_STRING"); yy.stringBufferStart = yylloc };
<INITIAL>[']                                      { this.begin("SQ_STRING"); yy.stringBufferStart = yylloc };
<DQ_STRING>[^"\\]*                                yy.stringBuffer += yytext;
<SQ_STRING>[^'\\]*                                yy.stringBuffer += yytext;
<SQ_STRING,DQ_STRING>\\u\{[0-9A-Fa-f]+\}          yy.stringBuffer += String.fromCodePoint( parseInt( yytext.slice(3, -1), 16 ) );
<SQ_STRING,DQ_STRING>\\\0                         yy.stringBuffer += "\u0000";
<SQ_STRING,DQ_STRING>\\\a                         yy.stringBuffer += "\u0008";
<SQ_STRING,DQ_STRING>\\\b                         yy.stringBuffer += "\b";
<SQ_STRING,DQ_STRING>\\\t                         yy.stringBuffer += "\t";
<SQ_STRING,DQ_STRING>\\\n                         yy.stringBuffer += "\n";
<SQ_STRING,DQ_STRING>\\\v                         yy.stringBuffer += "\v";
<SQ_STRING,DQ_STRING>\\\f                         yy.stringBuffer += "\f";
<SQ_STRING,DQ_STRING>\\\r                         yy.stringBuffer += "\r";
<SQ_STRING,DQ_STRING>\\\e                         yy.stringBuffer += "\u001B";
<SQ_STRING,DQ_STRING>\\.                          yy.stringBuffer += yytext[1];
<DQ_STRING>["]                                    {
                                                    yytext = yy.stringBuffer;
                                                    yylloc.first_line = yy.stringBufferStart.first_line;
                                                    yylloc.first_column = yy.stringBufferStart.first_column;
                                                    yy.stringBuffer = "";
                                                    this.popState();
                                                    return 'STRING'
                                                  }
<SQ_STRING>[']                                    {
                                                    yytext = yy.stringBuffer;
                                                    yylloc.first_line = yy.stringBufferStart.first_line;
                                                    yylloc.first_column = yy.stringBufferStart.first_column;
                                                    yy.stringBuffer = "";
                                                    this.popState();
                                                    return 'STRING'
                                                  }

"->"                                              return '->';
"?"                                               return '?';

\d+(\.\d+)?                                       return 'NUMBER';
\.\d+                                             return 'NUMBER';
"0x"[0-9a-fA-F]+                                  { yylval = base.hex(yytext); return 'NUMBER' };
"0o"[0-7]+                                        { yylval = base.oct(yytext); return 'NUMBER' };
"0b"[0-1]+                                        { yylval = base.bin(yytext); return 'NUMBER' };

if                                                return yytext;
else                                              return yytext;

let                                               return yytext;
const                                             return yytext;

"="                                               return '=';

"."                                               return '.';
","                                               return ',';
{VARIABLE_HEAD}{VARIABLE_TAIL}*                   return 'VARIABLE';
"["                                               return '[';
"]"                                               return ']';
"("                                               return '(';
")"                                               return ')';
"{"                                               return '{';
"}"                                               return '}';

"@"[A-Za-z0-9_$]+                                 { yytext = yytext.substring(1); return 'SYMBOL' };


";"                                               return 'SB';
\n                                                return 'SB';
\r                                                return 'SB';
<<EOF>>                                           return 'SB';

[^\S\n]+                                          ; // Whitespace
.                                                 return yytext

%%
