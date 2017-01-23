%start Entry

%{
    // Import our ASTNode classes
    var node = require('./nodes');
%}

%token LPAREN '('
%token RPAREN ')'

%token COMMA  ','
%token DOT    '.'

%%

Entry
    : Program { return $1 }
    ;

Program
    : Program Statements -> $1.concat($2)
    |                    -> []
    ;

Statements
    : Statement SB       -> [ $1 ]
    | SB                 -> []
    ;

Statement
    : Expression
    ;

Expression
    : PropertyExpression            -> new node.ExpressionStatement(@1, $1)
    ;

// Handle Properties
//
// Properties are generally parsed using:
//     P_a P_b*
// so P_b can be considered in the format:
//     I_a I_b I_c

PropertyExpression
    : PropertyHead PropertyTail     -> new node.PropertyExpression(@2, $1, $2)
    | PropertyHead
    ;

PropertyHead
    : Identifier
    | Literal
    ;

PropertyTail
    : PropertyTail PropertyTailItem -> $1.concat($2)
    | PropertyTailItem              -> [ $1 ]
    ;

PropertyTailItem
    : '.' Identifier                -> $2
    | '[' Expression ']'            -> new node.EvaluatedIdentifier(@2, $2)
    | '(' List ')'                  -> new node.ArgumentList(@2, $2)
    ;

/**
 * Literals
 *
 * This provides the `Literal` rule
 * which returns a literal, wrapped
 */

Literal
    : Number
    | String
    ;

Number
    : NUMBER -> new node.NumberLiteral(@1, $1)
    ;

String
    : STRING -> new node.StringLiteral(@1, $1)
    ;

/**
 * "Helper" Rules
 *
 * These don't necessarily directly parse anything
 * but these can provide simple wrappers or help
 * parse other things
 */

List
    : ListItems
    |                     -> []
    ;
ListItems
    : List COMMA Expression -> $1.concat($3)
    | Expression          -> [ $1 ]
    ;

Identifier
    : VARIABLE -> new node.Identifier(@1, $1)
    ;
