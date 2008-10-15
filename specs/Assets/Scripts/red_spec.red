class Spec
  attr_accessor :name, :block
  
  def initialize(name, &block)
    @name  = name.to_s
    @block = block
  end
  
  def block_to_js_object
    
  end
  
  def to_js_spec
    puts `#{@block}._block`
    `describe(#{@name}._value, {})`
  end
end

# calls JSSpec function 'describe'
# describe('what', {
#         'one': function() {
#           test experssions
#         },
#         'two': function() {
#           test experssions
#         }
# })
def it(name, &block)
  puts `#{block}._block`
end

def describe(what, &block)
  Spec.new(what, &block).to_js_spec
end