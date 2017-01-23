var x = require( './lib/parser.js' );
var util = require( 'util' );
var fs = require( 'fs' );
x.yy = { stringBuffer: "" };
var res = util.inspect( x.parse( fs.readFileSync("test", "utf8") ), false, null);
console.log(x);
console.log();
console.log(
    res
);
