# Parses most literals. This excludes
# complex literals such as switch literals

@{% var t = require('./nodes'); %}

# General items
integer -> [0-9]:+ {% d => d[0].join("") %}
hex -> [0-9A-Fa-f]:+ {% d => d[0].join("") %}

# Identifiers
identifier -> [A-Za-z] [A-Za-z0-9]:* {% (d, l) => new t.Identifier(l, d[0] + d[1].join("")) %}

# Numbers
number -> "-":? integer ("." integer {% d => d.join("") %}):? {% (d, l) => new t.NumberLiteral(l, d.join("")) %}
    | "-":? ("." integer {% d => d.join("") %}) {% (d, l) => new t.NumberLiteral(l, d.join("")) %}

# Strings
string -> "\"" dqStr:* "\"" {% (d, l) => new t.StringLiteral(l, d[1].join("")) %}
    | "'" sqStr:* "'" {% (d, l) => new t.StringLiteral(l, d[1].join("")) %}

dqStr -> [^"\\] {% d => d[0] %}
    | "\\\"" {% d => "\"" %}
    | strEscape

sqStr -> [^'\\] {% d => d[0] %}
    | "\\'" {% d => "'" %}
    | strEscape

strEscape -> "\\0" {% d => "\u0000" %}
    | "\\b" {% d => "\b" %}
    | "\\t" {% d => "\t" %}
    | "\\n" {% d => "\n" %}
    | "\\v" {% d => "\v" %}
    | "\\f" {% d => "\f" %}
    | "\\r" {% d => "\r" %}
    | "\\e" {% d => "\u001B" %}
    | "\\" . {% d => d[1] %}
