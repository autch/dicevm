# -*- mode: ruby; encoding: utf-8; -*-

class DiceNotationRuntime
  attr_reader :is # insn array
  attr_reader :ip # insn pointer, index of is
  attr_reader :ds # data stack
  attr_reader :cs # call stack
  
  def initialize(insn = nil)
    self.reset(insn)
  end

  def reset(insn)
    @is = insn ? insn.dup : nil
    @ds = []
    @cs = []
    @ip = 0
  end

  def run()
    until @is.empty? do
      break unless self.step
    end
    @ds.shift
  end

  def step()
    v = @is[@ip]
    @ip += 1
    p [v, @ds, @cs]
    case
    when v.nil?
      nil
    when v.is_a?(Fixnum)
      @ds << v
    when v.is_a?(Symbol)
      self.send(v)
    else
      raise "Unexpected token: #{v}"
    end
  end

  # ---- helpers

  def with_args(num_of_operands)
    if num_of_operands.respond_to?(:minmax) then
      v = @ds.pop(num_of_operands.max).reverse
      raise "Stack underflow" if v.length < num_of_operands.min
    else
      v = @ds.pop(num_of_operands).reverse
      raise "Stack underflow" if v.length < num_of_operands
    end
    yield(*v)
  end

  # ---- insns

  def lit; @ds << self.with_args(1){|v| v }; end
  def add; @ds << self.with_args((1..2)){|x, y| x.to_i + y.to_i }; end
  def sub; @ds << self.with_args((1..2)){|x, y| x.to_i - y.to_i }; end
  def mul; @ds << self.with_args((1..2)){|x, y| x.to_i * y.to_i }; end
  def div; @ds << self.with_args((1..2)){|x, y| x.to_i / y.to_i }; end
  def max; @ds << self.with_args(2){|x, y| x > y ? x : y}; end
  def min; @ds << self.with_args(2){|x, y| x < y ? x : y}; end
  def roll; @ds << self.with_args(1){|v| Kernel.rand(v) + 1}; end
  def keep_highest
    @ds += self.with_args(2){|keep, num_values|
      values = @ds.pop(num_values)
      values.sort{|x, y| y <=> x }.first(keep)
    }
  end
  alias :push :lit
  def lt; @ds << self.with_args(2){|x, y| (x < y) ? 1 : 0 }; end
  def gt; @ds << self.with_args(2){|x, y| (x > y) ? 1 : 0 }; end
  def eq; @ds << self.with_args(2){|x, y| (x == y) ? 1 : 0 }; end
  def le; @ds << self.with_args(2){|x, y| (x <= y) ? 1 : 0 }; end
  def ge; @ds << self.with_args(2){|x, y| (x >= y) ? 1 : 0 }; end
  def ne; @ds << self.with_args(2){|x, y| (x != y) ? 1 : 0 }; end

  def dup
    @ds << @ds[-1]
  end

  def pop
    @ds.pop
  end

  def goto
    @ip = @ds.pop
  end

  def for
    skip = @ds.pop
    i = @ds.pop
    if i == 0 then
      @ip += skip - 1
    else
      @cs += [@ip, i]
    end
  end

  def next
    i = @cs.pop
    i -= 1
    if i > 0 then
      new_ip = @cs.pop
      @cs += [new_ip, i]
      @ip = new_ip
    else
      @cs.pop # new_ip
    end
  end
end

