var parser = require("./dice.js");
var runtime = require("./dice_runtime.js");
var readline = require('readline');

var rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

rl.setPrompt("DICE> ");
rl.prompt();

rl.on("line", function(line) {
    str = line;

    r = new runtime.DiceRuntime();
    r.event('beforeStep', function(ip, insn, ds, cs) {
        console.log("IP(", this.ip - 1, "): ", insn, ", DS:", this.ds, "CS:", this.cs); // DEBUG
    });
    
    try {
        insn = parser.parse(str);
        console.log("INSN: ", insn);
        r.reset(insn);
        v = r.run();
        console.log("=>", v);
    } catch(e) {
        console.log(e, e.stack);
    }

    rl.prompt();
}).on("close", function() {
    process.exit(0);
});

