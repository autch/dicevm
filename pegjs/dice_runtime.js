module.exports = (function(){

    function DiceRuntime(insn) {
        this.reset(insn);
    }

    DiceRuntime.prototype.reset = function(insn) {
        this.is = insn ? insn : null; // insn array (memory)
        this.ds = [];                 // data stack
        this.cs = [];                 // call stack
        this.ip = 0;                  // insn pointer, index of is
    };

    DiceRuntime.prototype.run = function() {
        while(this.is.length > 0) {
            if(!this.step())
                break;
        }
        return this.ds.shift();
    };

    DiceRuntime.prototype.step = function() {
        var v = this.is[this.ip++];

        if(!v) {
            return false;
        }
        console.log("IP(", this.ip - 1, "): ", v, this.ds, this.cs); // DEBUG

        if(v % 1 === 0) {
            this.ds.push(v);
        } else if(typeof v === "string" || v instanceof String) {
            this.insns[v].call(this, v);
        } else {
            throw "unexpected insn token: " + v;
        }
        return true;
    };

    DiceRuntime.prototype.withArgs = function(arity, callback) {
        var values = [], m, l;
        if(Array.isArray(arity)) {
            m = arity[1]; l = arity[0];
        } else if(arity % 1 === 0) {
            m = l = arity;
        }
        for(var i = 0; i < m && this.ds.length > 0; i++) {
            values.push(this.ds.pop());
        }
        if(values.length < l)
            throw "Stack underflow";
        return callback.apply(this, values);
    };

    DiceRuntime.prototype.push = function(s, v) {
        if(Array.isArray(v)) {
            for(var i = 0, l = v.length; i < l; i++) {
                s.push(v[i]);
            }
        } else {
            s.push(v);
        }
    };

    DiceRuntime.prototype.pop = function(s, n) {
        if(typeof n === "undefined") {
            return s.pop();
        } else {
            var r = [];
            for(var i = 0; i < n; i++) {
                r.unshift(s.pop());
            }
            return r;
        }
    };

    DiceRuntime.prototype.keep = function(callback) {
        return function(keep, num_values) {
            var values = this.pop(this.ds, num_values);
            values.sort(callback);
            return values.slice(0, keep);
        };
    };

    DiceRuntime.prototype.insns = {
        lit: function() { this.ds.push(this.withArgs(1, function(v) { return v; })); },
        add: function() { this.ds.push(this.withArgs([1,2], function(x, y) { return x + y; })); },
        sub: function() { this.ds.push(this.withArgs([1,2], function(x, y) { return x - y; })); },
        mul: function() { this.ds.push(this.withArgs([1,2], function(x, y) { return x * y; })); },
        div: function() { this.ds.push(this.withArgs([1,2], function(x, y) { return x / y; })); },

        max: function() { this.ds.push(this.withArgs(2, function(x, y) { return x > y ? x : y; })); },
        min: function() { this.ds.push(this.withArgs(2, function(x, y) { return x < y ? x : y; })); },

        roll: function() { this.ds.push(this.withArgs(1, function(v) { return Math.floor(Math.random() * v) + 1; })); },
        keep_highest: function() { this.push(this.ds, this.withArgs(2, this.keep(function(x, y) { return y - x; }))); },
        keep_lowest: function() { this.push(this.ds, this.withArgs(2, this.keep(function(x, y) { return x - y; }))); },

        dup: function() { this.ds.push(this.ds.slice(-1)); },
        push: function() { this.insns.lit(); },
        pop: function() { this.ds.pop(); },

        for: function() {
            var skip, i;
            skip = this.ds.pop();
            i = this.ds.pop();
            if(i == 0) {
                this.ip += skip - 1;
            } else {
                this.cs = this.cs.concat(this.ip, i);
            }
        },
        next: function() {
            var i, new_ip;
            i = this.cs.pop();
            if(--i > 0) {
                new_ip = this.cs.pop();
                this.cs = this.cs.concat(new_ip, i);
                this.ip = new_ip;
            } else {
                this.cs.pop();
            }
        }
    };

    var result = {};

    result.DiceRuntime = DiceRuntime;
    
    return result;
})();
