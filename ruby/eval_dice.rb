#!/usr/bin/env ruby

require_relative 'dice.tab.rb'
require_relative 'dice_runtime.rb'

d = DiceNotationParser.new
r = DiceNotationRuntime.new

while line = ARGF.gets do 
  s = line.chop
  next if /^\s*$/ =~ s

  unless $stdin.isatty then
    print " <= ", s, "\n"
  end

  begin
    insn_stack = d.parse(s)
    p insn_stack
    r.reset(insn_stack)
    v = r.run
    print " => #{v}\n"
  rescue ParseError
    puts $!
  end
end
