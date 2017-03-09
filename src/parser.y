%start Entry

%{
    // Import our ASTNode classes
    var node = require('./nodes');
%}

%token LAMBDA_INDICATOR

%nonassoc IF_NO_ELSE
%nonassoc else

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
    : VariableDeclaration 
    | IfStatement
    | Expression
    ;

/**
 * VariableDeclaration
 *
 * I might misspell this so sorry in advance
 */

VariableDeclaration
    : DeclarationModifier TypedIdentifier DeclarationSuffix -> new node.DeclarationStatement(@$, $1, $2, $3)
    ;

DeclarationModifier
    : let
    | const
    ;

DeclarationSuffix
    : '=' Expression                                       -> $2
    |                                                      -> null
    ;

/**
 * Unbound Statement
 *
 * Series of statements not bound to end
 */

UnboundStatement
    : UnboundStatement SB Statement
    | Statement
    ;

/**
 * If Statement
 *
 * : if ( Expression ) { Statements } [IfSuffix]
 * | if ( Expression ) Statement      [IfSuffix]
 */

IfStatement
    : if '(' Expression ')' '{' UnboundStatement '}' IfSuffix -> [ $Expression, $UnboundStatement, $IfSuffix ]
    | if '(' Expression ')'            Statement     IfSuffix -> [ $Expression, $Statement, $IfSuffix ]
    ;

IfSuffix
    : else '{' UnboundStatement '}'
    | else            Statement
    | %prec IF_NO_ELSE
    ;

/**
 * Expressions
 *
 * This fullfills both as a statement and
 * all other fragment usages
 */

Expression
    : PropertyExpression            -> new node.ExpressionStatement(@1, $1)
    | IndependentLiteral            -> new node.ExpressionStatement(@1, $1)
    ;

// Handle Properties
//
// Properties are generally parsed using:
//     P_a P_b*
// so P_b can be considered in the format:
//     I_a I_b I_c

PropertyExpression
    : PropertyHead PropertyTail    -> new node.PropertyExpression(@2, $1, $2)
    | PropertyHead 
    ;

PropertyHead
    : Literal
    | Identifier
    | '(' Expression ')'           -> $2
    ;

PropertyTail
    : PropertyTail PropertyTailItem -> $1.concat($2)
    | PropertyTailItem              -> [ $1 ]
    ;

PropertyTailItem
    : '.' Identifier               -> $2
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

IndependentLiteral
    : Lambda
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

/* Lambdas are a mix of the "function" section and this */
Lambda
    : FunctionHead '->' LambdaBody -> new node.Lambda(@$, $1, $2)
    | '->' LambdaBody
    ;

// TODO: include "return" statement
LambdaBody
    :
    ;

/**
 * "Function" Rules
 *
 * Defines a series of rules for parsing functions
 */

FunctionHead
    : '(' FunctionHeadItems ')' -> $2
    ;

FunctionHeadItems
    : 
    | FunctionHeadItem                       -> [ $1 ]
    | FunctionHeadItems ',' FunctionHeadItem -> $1.concat($3)
    ;

// TODO: Solve conflict with typed Identifiers
FunctionHeadItem
    : Identifier '?'                    -> new node.FunctionArgument(@$, [$1, $2], true)
    | Identifier                        -> new node.FunctionArgument(@$, [$1, $2], false)
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

TypedIdentifier
    : VARIABLE ':' Identifier -> [$1, $3]
    | VARIABLE                -> [$1, null]
    ;
