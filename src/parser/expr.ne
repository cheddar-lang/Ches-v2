# Parses an expression
# `Expression` maybe empty

@include "parser/literals.ne"
@include "parser/ws.ne"

Expression -> Property {% id %}

# Macros
List[x] -> $x ( "," $x {% d => d[1][0] %} ):* ",":? {% d => d[0].concat(d[1]) %}

# Properies
Property -> propertyHead (_ propertyTail {% d => d[1] %}):* {% (d, l) => d[1].length === 0 ? d[0] : new t.PropertyExpression(l, d[0], d[1]) %}

propertyHead -> Literal {% id %} | identifier {% id %}
propertyTail -> "." _ identifier {% d => d[2] %}
    | "[" _ Expression _ "]" {% (d, l) => new t.EvaluatedIdentifier(l, d[2]) %}

Literal -> number {% id %} | string {% id %}

# Types
TypedIdentifier -> identifier

# Lambdas
