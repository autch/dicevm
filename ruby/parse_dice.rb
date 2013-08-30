#!/usr/bin/env ruby

require_relative 'dice.tab.rb'

d = DiceNotationParser.new
#d.instance_eval{ @yydebug = true }

while line = ARGF.gets do 
  s = line.chop
  next if /^\s*$/ =~ s

  unless $stdin.isatty then
    puts s
  end

  begin
    insn_stack = d.parse(s)
    p insn_stack
  rescue ParseError
    puts $!
  end
end
