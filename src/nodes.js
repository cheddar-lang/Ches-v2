[
    "ExpressionStatement",
    "PropertyExpression",
    "ArgumentList", "EvaluatedIdentifier",
    "StringLiteral", "NumberLiteral", "ArrayLiteral", "SymbolLiteral", "DictionaryLiteral",
    "Identifier"
].forEach(name => module.exports[name] = require("./Nodes/" + name) )
