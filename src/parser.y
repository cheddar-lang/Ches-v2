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
    | Array
    | Symbol
    | Dictionary
    ;

Number
    : NUMBER       -> new node.NumberLiteral(@1, $1)
    ;

Array
    : '[' List ']' -> new node.ArrayLiteral(@$, $2)
    ;

String
    : STRING       -> new node.StringLiteral(@$, $1)
    ;

Symbol
    : SYMBOL       -> new node.SymbolLiteral(@$, $1)
    ;

/* Dictionaries are a little harder so just a little section here for them */
Dictionary
    : '[' DictionaryItems ']' -> new node.DictionaryLiteral(@2, $2)
    | '[' ':' ']'             -> new node.DictionaryLiteral(@$, [])
    ;

DictionaryItems
    : DictionaryItems ',' DictionaryItem -> $1.concat([$3])
    | DictionaryItem                     -> [ $1 ]
    ;

DictionaryItem
    : Expression ':' Expression          -> [ $1, $3 ]
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
    : ListItems ',' Expression -> $1.concat($3)
    | Expression               -> [ $1 ]
    ;

Identifier
    : VARIABLE -> new node.Identifier(@1, $1)
    ;
