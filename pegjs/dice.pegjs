/* -*- encoding: utf-8-unix; -*- */

{
  Array.prototype.flatten = function() {
    return Array.prototype.concat.apply([], this);
  };

  function fillArray(value, n) {
    var a = [];
    while(n--) { a.push(value); }
    return a;
  }

  function generateBinary(op, left, rest) {
    return [rest, left, op].flatten();
  }
  function generateFor(count, body) {
    if(count == 0) return [];
    if(count == 1) return [body];
    var b = body;
    return [count, b.length, 'for', b, 'next'].flatten();
  }

}

start
  = expr:expr { return expr; }
  /           { return []; }

expr
  = times

primary
  = number
  / '(' _ val:expr _ ')'           { return val; }

unary
  = val:primary '%'       { return [val, 100, 'mul'].flatten(); }
  / '-' val:primary           { return -val; }
  / roll
  / primary

sum
  = left:prod _ '+' _ right:sum { return generateBinary('add', left, right); }
  / left:prod _ '-' _ right:sum { return generateBinary('sub', left, right); }
  / prod

prod
  = left:unary _ '*' _ right:prod { return generateBinary('mul', left, right); }
  / left:unary _ '/' _ right:prod { return generateBinary('div', left, right); }
  / unary

times
  = left:sum _ 'x' _ right:primary { return generateFor(right, left).concat(fillArray('add', right - 1)).flatten(); }
  / sum

roll
  = d:dice 'd' s:sides spec:bound_spec {
      var r = generateFor(d, [s, 'roll']);
      if(spec instanceof Array) {
        r = r.concat(d, spec[1], spec[0]);
        d = spec[1];
        spec = 'add';
      }
      return r.concat(fillArray(spec, d - 1)).flatten();
    }

dice
  = n:number              { return n; }
  /                       { return 1; }

sides
  = n:number              { return n; }
  /                       { return 6; }

bound_spec
  = 'L'i                  { return 'min'; }
  / 'H'i                  { return 'max'; }
  / 'K' n:number          { return ['keep_highest', n]; }
  / 'k' n:number          { return ['keep_lowest', n]; }
  /                       { return 'add'; }

number
  = v:[0-9]+              { return parseInt(v.join(""), 10); }

_
  = [ \t]+                /* eat up all spaces */
  /

