var $ = require('jquery');
var parser = require('./dice.js');
var runtime = require('./dice_runtime.js');
var r = new runtime.DiceRuntime();

$(function() {
    $("form button").on("click", function() {
        var source = $('#dice').val();
        var $result = $('#result');
        var $console = $('#console');

        $console.write = function(v) {
            var $this = $(this);
            var t = $this.val();
            t += v + "\n";
            $this.val(t);
            return $this;
        };
                
        r.event('beforeStep', function(ip, insn, ds, cs) {
            var t = "IP(" + (this.ip - 1) + "): " + insn +
                    ", DS:[" + this.ds +
                    "], CS:[" + this.cs + "]";
            $console.write(t);
        });
        
        $console.val("SRC: \"" + source + "\"\n");
        try {
            var insn = parser.parse(source);
            $console.write("INSN: [" + insn + "]");
            r.reset(insn);
            var v = r.run();
            console.log("=>", v);
            $console.write("# => " + v);
            $result.val(v);
        } catch(e) {
            console.log(e, e.stack);
        }

        return false;
    });
});
