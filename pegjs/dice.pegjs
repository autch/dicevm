/* -*- encoding: utf-8-unix; -*- */

{
  Array.prototype.flatten = function() {
    return Array.prototype.concat.apply([], this);
  };

  function fill_array(value, n) {
    var a = [];
    while(n--) { a.push(value); }
    return a;
  }

  function generate_binary(op, left, rest) {
    return [rest, left, op].flatten();
  }
  function generate_for(count, body) {
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
  = left:prod _ '+' _ right:sum { return generate_binary('add', left, right); }
  / left:prod _ '-' _ right:sum { return generate_binary('sub', left, right); }
  / prod

prod
  = left:unary _ '*' _ right:prod { return generate_binary('mul', left, right); }
  / left:unary _ '/' _ right:prod { return generate_binary('div', left, right); }
  / unary

times
  = left:sum 'x' right:primary { return generate_for(right, left).concat(fill_array('add', right - 1)).flatten(); }
  / sum

roll
  = d:dice 'd' s:sides spec:bound_spec {
      var r = generate_for(d, [s, 'roll']);
      if(spec instanceof Array) {
        r = r.concat(d, spec[1], spec[0]);
        d = spec[1];
        spec = 'add';
      }
      return r.concat(fill_array(spec, d - 1)).flatten();
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

