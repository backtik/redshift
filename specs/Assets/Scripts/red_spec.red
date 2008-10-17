class Spec
  attr_accessor :name, :block, :buffer
  
  def self.describe(name, &block)
    s = Spec.new(name, &block)
    block.call(s)
    s.to_js_spec
  end
  
  def initialize(name, &block)
    @name   = name.to_s
    @block  = block
    @buffer = []
  end
  
  def to_js_spec
    `a = {}`
    self.buffer.each do |pair|
      `a[#{pair[0]}] = #{pair[1]}`
    end
    `describe(#{@name}._value, a)`
  end
  
  def value_of(expression)
    `JSSpec.DSL.value_of(expression)`
  end
  
  def should_be(value)
    `#{self}.should_be(value)`
  end
  
  def verb(display_name, name, &block)
    self.buffer << [(display_name + ' ' + name), `#{block}._block`]
  end
  
  def should(name, &block)
    self.verb('should', name, &block)
    # self.buffer << [('can ' + name), `#{block}._block`]
  end
  
  def can(name, &block)
    self.verb('can', name, &block)
  end
  
  def needs(name, &block)
    self.verb('needs', name, &block)
  end
  
  def is(name, &block)
   self.verb('is', name, &block)
  end
end