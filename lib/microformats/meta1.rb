module Kernel
  def block_with_method_missing(block1, &block2)
    (class << block1
      self
    end.module_eval do
      define_method(:method_missing, &block2)
      define_method(:call){block1.instance_eval(&block1)}
    end
    block1
  end
end

class Foo
  def bar(&block)
    block = method_missing_inspect(block)
    block.call
  end

  def method_missing_inspect(block)
    block_with_method_missing(block) do |method_name, *args|
      p [:mm, method_name, args]
    end
  end
end 