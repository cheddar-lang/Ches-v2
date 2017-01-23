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
    var stringBuffer = "";
%}

%lex
%options flex

%x MULTILINE_COMMENT

VARIABLE_HEAD [A-Za-z_$]
VARIABLE_TAIL [A-Za-z_$0-9]

%x DQ_STRING
%x SQ_STRING

%%

// Ignore the followings things because we don't like them

"//".*                                            ;

// Handles Multiline comments
("/*")                                            this.begin("MULTILINE_COMMENT");
<MULTILINE_COMMENT>(?:[^/*]|"*"[^/]|"/"[^*])+     ;
<MULTILINE_COMMENT>("*/")                         this.popState();

<INITIAL>["]                                      this.begin("DQ_STRING");
<INITIAL>[']                                      this.begin("SQ_STRING");
<DQ_STRING>[^"\\]*                                stringBuffer += yytext;
<SQ_STRING>[^'\\]*                                stringBuffer += yytext;
<SQ_STRING,DQ_STRING>\\u\{[0-9A-Fa-f]+\}          stringBuffer += String.fromCodePoint( parseInt( yytext.slice(3, -1), 16 ) );
<SQ_STRING,DQ_STRING>\\\0                         stringBuffer += "\u0000";
<SQ_STRING,DQ_STRING>\\\a                         stringBuffer += "\u0008";
<SQ_STRING,DQ_STRING>\\\b                         stringBuffer += "\b";
<SQ_STRING,DQ_STRING>\\\t                         stringBuffer += "\t";
<SQ_STRING,DQ_STRING>\\\n                         stringBuffer += "\n";
<SQ_STRING,DQ_STRING>\\\v                         stringBuffer += "\v";
<SQ_STRING,DQ_STRING>\\\f                         stringBuffer += "\f";
<SQ_STRING,DQ_STRING>\\\r                         stringBuffer += "\r";
<SQ_STRING,DQ_STRING>\\\e                         stringBuffer += "\u001B";
<SQ_STRING,DQ_STRING>\\.                          stringBuffer += yytext[1];
<DQ_STRING>["]                                    { yytext = stringBuffer; stringBuffer = ""; this.popState(); return 'STRING' }
<SQ_STRING>[']                                    { yytext = stringBuffer; stringBuffer = ""; this.popState(); return 'STRING' }

\d+(\.\d+)?                                       return 'NUMBER';
\.\d+                                             return 'NUMBER';
"0x"[0-9a-fA-F]+                                  { yylval = base.hex(yytext); return 'NUMBER' };
"0o"[0-7]+                                        { yylval = base.oct(yytext); return 'NUMBER' };
"0b"[0-1]+                                        { yylval = base.bin(yytext); return 'NUMBER' };

"."                                               return '.';
","                                               return ',';
{VARIABLE_HEAD}{VARIABLE_TAIL}*                   return 'VARIABLE';
"["                                               return '[';
"]"                                               return ']';
"("                                               return '(';
")"                                               return ')';


";"                                               return 'SB';
\n                                                return 'SB';
<<EOF>>                                           return 'SB';
