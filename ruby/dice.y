# -*- mode: ruby; encoding: utf-8; -*-

class DiceNotationParser
prechigh
  left 'x'
  left 'd'
  nonassoc UMINUS
  left '*' '/' '%'
  left '+' '-'
preclow
rule
  goal: expr		{ result = val[0] }
  |			{ result = [] }

  expr: expr '+' expr	{ result = [val[0], val[2], :add].flatten }
  | expr '-' expr	{ result = [val[0], val[2], :sub].flatten }
  | expr '*' expr	{ result = [val[0], val[2], :mul].flatten }
  | expr '/' expr	{ result = [val[0], val[2], :div].flatten }
  | '(' expr ')'	{ result = val[1] }
  | expr '%'		{ result = [val[0], 100, :mul].flatten }
  | '-' NUMBER = UMINUS	{ result = -val[1] }
  | roll		{ result = val[0] }
  | NUMBER              { result = val[0] }
  | NUMBER 'x' expr	{ result = (gen_for_loop(val[0], val[2]) + ([:add] * (val[0] - 1))).flatten }
  | expr 'x' NUMBER	{ result = (gen_for_loop(val[2], val[0]) + ([:add] * (val[2] - 1))).flatten }

  roll: opt_num 'd' opt_num opt_bound {
    d = val[0] ? val[0] : 1
    f = val[2] ? val[2] : 6

    if val[3][1] != :keep_highest then
      r = gen_for_loop(d, [f, :roll]) + ([val[3]] * (d - 1))
    else
      r = gen_for_loop(d, [f, :roll]) + [d, val[3]] + ([:add] * (val[3][0] - 1))
    end

    result = r.flatten
  }

  opt_num: NUMBER	{ result = val[0] }
  |			{ result = nil }

  opt_bound:		{ result = :add }
  | BOUND		{ result = val[0] == 'L' ? :min : :max }
  | 'k' NUMBER		{ result = [val[1], :keep_highest] }
end

---- inner

def gen_for_loop(count, body)
  if count > 1 then
    [count, body.flatten.length, :for, body.flatten, :next].flatten
  else
    body
  end
end

def parse(str)
  @tokens = []

  until str.empty?
    case str
    when /\A\s+/
      # eat up all spaces
    when /\A\d+/
      @tokens.push [:NUMBER, $&.to_i]
    when /\A-([LH])/
      @tokens.push [:BOUND, $1]
    when /\A.|\n/o
      @tokens.push [$&, $&]
    end
    str = $'
  end
  @tokens.push [false, '$end']
  do_parse
end

def next_token()
  @tokens.shift
end

def on_error(token_id, value, stack)
  print "Parse error at #{value} (#{token_to_str token_id})\n"
  print "Value stack: #{stack.inspect}\n"
end
