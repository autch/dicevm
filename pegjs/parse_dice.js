var parser = require("./dice.js");
var readline = require('readline');

var rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

rl.setPrompt("DICE> ");
rl.prompt();

rl.on("line", function(line) {
    str = line;

    v = parser.parse(str);

    console.log(v);

    rl.prompt();
}).on("close", function() {
    process.exit(0);
});

