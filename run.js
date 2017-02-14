var x = require( './lib/parser.js' );
var util = require( 'util' );
var fs = require( 'fs' );

var string = process.argv[2] || fs.readFileSync("test", "utf8") ;

x.parser.yy.parseError = function(_, data) {
    var no_color = false;

    function padRight(string, length) {
        return " ".repeat(length - string.length) + string;
    }

    function getLine(string, line) {
        var occurences = 0;
        var res;
        var pos = 0;
        var mark;
        while (occurences <= line) {
            if ((string[pos] === '\n' || !string[pos]) && occurences == line)
                return string.substring(mark, pos);

            if (!string[pos])
                return false;

            if (string[pos] === '\n') {
                mark = pos + 1;
                occurences++;
            }

            pos++;
        }
    }

    function lineCount(string) {
        var count = 0;
        for (var i = 0; i < string.length; i++) {
            if (string[i] == '\n') count++;
        }
        return count;
    }

    function generateLines() {
        var start_color = no_color === true ? "" : "\u001b[33m";
        var end_color = no_color === true ? "" : "\u001b[0m"

        var desired_lines = 1; // Attempt to add these many lines too top & bottom
        var loc = data.loc;

        var res_string = "";

        var bottom_line = loc.first_line - desired_lines;
        var top_line = loc.last_line + desired_lines;

        // Ensure within range
        bottom_line = Math.max(1, bottom_line - 1);
        top_line = Math.max(lineCount(string), top_line - 1);

        // Number of lines to mark
        var line_range = loc.last_line - loc.first_line + 1;

        var line_number_length = (top_line + "").length;

        var sep = " | "
            var cur_line;
        for (var i = bottom_line; i <= top_line; i++) {
            cur_line = getLine(string, i - 1);
            res_string += start_color + padRight(i + "", line_number_length) + sep + end_color +
                cur_line + "\n";
            if (i >= loc.first_line && i <= loc.last_line) {
                res_string += " ".repeat(line_number_length) + start_color + sep +
                    " ".repeat(loc.first_column) + "^".repeat(Math.max(1, loc.last_column - loc.first_column)) + end_color + "\n";
            }
        }

        return res_string;
    }

    function normalize(text) {
        if (lineCount(string) == data.line && !getLine(string, data.line)[data.loc.last_column + 1])
            return "end of input";

        if (text === '\n')
            return "newline";

        return "token `" + text + "`";
    }

    function determineError() {
        var red = no_color === true ? "" : "\u001b[31m";
        var bold = no_color === true ? "" : "\u001b[1m";
        var def = no_color === true ? "" : "\u001b[0m";

        return bold + red + "Syntax Error: " + def +
            "Unexpected " + bold + normalize(data.text) + def + " at " + data.loc.first_line + ":" + data.loc.first_column;
    }

    function findSolution() {
        var braces = [ ']', ')', '}' ];

        var token = data.text;

        var brace_solutions = 0;
        var brace;

        main_1:
        for (var i = 0; i < data.expected.length; i++) {
            for (var j = 0; j < braces.length; j++) {
                if (data.expected[i] == "'" + braces[j] + "'") {
                    if (brace_solutions >= 1) {
                        brace_solutions++;
                        break main_1;
                    } else {
                        brace = braces[j];
                        brace_solutions++;
                        break;
                    }
                }
            }
        }

        var solutions = [];

        if (brace_solutions === 1)
            if (token === '\n')
                solutions.push( "Attempt to add missing `" + brace + "`" );
            else
                solutions.push( "Expecting closing `" + brace + "`" );

        if (solutions.length <= 0) return "";

        var res = "\n\n";
        for (var i = 0; i < solutions.length; i++) {
            res += "    \u2022 " + solutions[i] + "\n";
        }
        return res;
    }

    console.error( generateLines() + "\n" + determineError() + findSolution() );
    process.exit(1);
}
var res = util.inspect( x.parse( string ), false, null);
console.log(x);
console.log();
console.log(
        res
);
