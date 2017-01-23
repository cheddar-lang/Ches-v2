[
    "ExpressionStatement",
    "PropertyExpression",
    "ArgumentList", "EvaluatedIdentifier",
    "StringLiteral", "NumberLiteral",
    "Identifier"
].forEach(name => module.exports[name] = require("./Nodes/" + name) )
