[
    "ExpressionStatement", "DeclarationStatement",
    "PropertyExpression",
    "ArgumentList", "EvaluatedIdentifier", "FunctionArgument",
    "StringLiteral", "NumberLiteral", "ArrayLiteral", "SymbolLiteral", "DictionaryLiteral", "Lambda",
    "Identifier"
].forEach(name => module.exports[name] = require("./Nodes/" + name) )
