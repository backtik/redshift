# Classes including module +Chainable+ gain the ability to cache a stack of
# +Proc+ objects. These blocks of code can later be executed one at a time, in
# the order of their insertion.
# 
#   class Foo
#     include Chainable
#   end
#   
#   foo = Foo.new
#   foo.chain {|x| puts "x: " + x }.chain {|y,z| puts ["y: %s","z: %s"].join("\n") % [y,z] }
#   
#   foo.call_chain('called 1st')
#   foo.call_chain('called 2nd', 'called 2nd also')
# 
# produces:
# 
#   x: called 1st
#   y: called 2nd
#   z: called 2nd also
# 
module Chainable
  # call-seq:
  #   chainable.call_chain(arg, ...) -> object or false
  # 
  # Removes the foremost +Proc+ from _chainable_'s chain and calls it,
  # returning the result. Returns +false+ if the chain was empty.
  # 
  #   chainable.chain {|x,y,z| x * (y + z) }
  #   
  #   chainable.call_chain(4,5,6)   #=> 44
  #   chainable.call_chain          #=> false
  # 
  def call_chain(*args)
    @chain ||= []
    return `#{@chain.shift}.__block__.apply(this,args)` unless @chain.empty?
    return false
  end
  
  # call-seq:
  #   chainable.chain { |arg,...| block } -> chainable
  # 
  # Adds _block_ to the end of _chainable_'s chain, then returns _chainable_.
  # 
  #   chainable.chain { puts 1; return 'called 1' }.chain { puts 2; return 'called 2' }
  #   
  #   chainable.call_chain    #=> "called 1"
  #   chainable.call_chain    #=> "called 2"
  #   chainable.call_chain    #=> false
  # 
  # produces:
  # 
  #   1
  #   2
  # 
  def chain(&block)
    @chain ||= []
    @chain << block
    return self
  end
  
  # call-seq:
  #   chainable.clear_chain -> chainable
  # 
  # Returns _chainable_ with its chain emptied.
  # 
  #   chainable.chain { 1 + 1 }
  #   
  #   chainable.clear_chain.call_chain    #=> false
  # 
  def clear_chain
    @chain ||= []
    @chain.clear
    return self
  end
end
