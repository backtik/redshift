# Module +CodeEvents+ enables event-driven programming by giving objects of
# the including class the ability to define custom observers and callbacks.
# 
#   class Looper
#     include CodeEvents
#     
#     def initialize(range)
#       @range = range
#     end
#     
#     def run(min, max)
#       self.fire(:start)
#       @range.each do |i|
#         self.fire(:minimum, 0, i) && next if i == min
#         self.fire(:maximum, 0, i) && next if i == max
#         puts i
#       end
#       return self
#     end
#   end
#   
#   looper = Looper.new(1..10)                                          #=> #<Looper:0x34fe78>
#   
#   looper.upon :start do
#     puts "The loop has begun"
#   end
#   
#   min_proc = Proc.new {|i| puts "Minimum amount reached: %s" % i }    #=> #<Proc:0x3e72a9>
#   max_proc = Proc.new {|i| puts "Maximum amount reached: %s" % i }    #=> #<Proc:0x3ea147>
#   looper.upon(:minimum => min_proc, :maximum => max_proc)             #=> #<Looper:0x34fe78>
#   
#   looper.run(3,8)                                                     #=> #<Looper:0x34fe78>
# 
# produces:
# 
#   The loop has begun
#   1
#   2
#   Minimum amount reached: 3
#   4
#   5
#   6
#   7
#   Maximum amount reached: 8
#   9
#   10
# 
module CodeEvents
  # call-seq:
  #   obj.fire(sym)                  -> obj
  #   obj.fire(sym, delay, arg, ...) -> obj
  # 
  # Instructs _obj_ to call the +Proc+ objects associated with the event
  # _sym_, then returns _obj_. Optionally delays the firing of the event by
  # _delay_ milliseconds. The second form allows passing of arguments to the
  # event's +Proc+ objects, but if any arguments are passed, the first must be
  # the _delay_ argument.
  # 
  #   obj.upon(:A) {|x| puts x }        #=> obj
  #   obj.upon(:B) {|y| puts y }        #=> obj
  #   obj.upon(:C) { puts 'fire 3' }    #=> obj
  #   
  #   obj.fire(:A, 500, 'fire 1').fire(:B, 0, 'fire 2').fire(:C)
  # 
  # produces:
  # 
  #   fire 2
  #   fire 3
  #   fire 1
  # 
  def fire(sym, delay, *args)
    name = sym.to_sym
    return self unless @code_events && events_group = @code_events[name]
    events_group.each do |proc|
      `var f=function(){return proc.__block__.apply(null,args);}`
      `if(delay){return setTimeout(f,delay);}`
      `f()`
    end
    return self
  end
  
  # call-seq:
  #   obj.ignore             -> obj
  #   obj.ignore(sym)        -> obj
  #   obj.ignore(sym, &proc) -> obj
  # 
  # Instructs _obj_ to ignore the specified event, then returns _obj_.
  # 
  # In the first form, all event-related +Proc+ objects not marked
  # as "unignorable" are removed from _obj_.
  # 
  #   obj.upon(:A, true) { puts '1st executed' }    #=> obj
  #   obj.upon(:A)       { puts '2nd executed' }    #=> obj
  #   obj.upon(:B)       { puts '3rd executed' }    #=> obj
  #   
  #   obj.ignore                                    #=> obj
  #   obj.fire(:A).fire(:B)                         #=> obj
  # 
  # produces:
  # 
  #   1st executed
  # 
  # In the second form, only the ignorable +Proc+ objects associated with the
  # event _sym_ are removed.
  # 
  #   obj.upon(:A, true) { puts '1st executed' }    #=> obj
  #   obj.upon(:A)       { puts '2nd executed' }    #=> obj
  #   obj.upon(:B)       { puts '3rd executed' }    #=> obj
  #   
  #   obj.ignore(:A)                                #=> obj
  #   obj.fire(:A).fire(:B)                         #=> obj
  # 
  # produces:
  # 
  #   1st executed
  #   3rd executed
  # 
  # In the third form, only the +Proc+ object passed in as <i>&proc</i> is
  # removed.
  # 
  #   proc_1 = Proc.new { puts 'Proc 1 executed' }    #=> #<Proc:0x3e78ee>
  #   proc_2 = Proc.new { puts 'Proc 2 executed' }    #=> #<Proc:0x3e888a>
  #   
  #   obj.upon(:A, &proc_1)                           #=> obj
  #   obj.upon(:A, &proc_2)                           #=> obj
  #   
  #   obj.ignore(:A, &proc_1)                         #=> obj
  #   obj.fire(:A)                                    #=> obj
  # 
  # produces:
  # 
  #   Proc 2 executed
  # 
  def ignore(sym, &block)
    if sym
      name = sym.to_sym
      return self unless @code_events && events_group = @code_events[name]
      if block
        events_group.delete(block) unless `block.__block__.__unignorable__`
      else
        events_group.each {|proc| self.ignore(name, &proc) }
      end
    else
      @code_events.each_key {|name| self.ignore(name) }
    end
    return self
  end
  
  # call-seq:
  #   obj.upon(sym, unignorable = false) { |arg,...| block } -> obj
  #   obj.upon(hash)                                         -> obj
  # 
  # Stores a number of +Proc+ objects to be called when the event _sym_ is
  # fired.
  # 
  # The first form adds _block_ to the array of +Proc+ objects executed when
  # the event _sym_ is fired, then returns _obj_. If _unignorable_ is set to
  # +true+, the _block_ will be executed when _sym_ fires, regardless of
  # whether it has been ignored.
  # 
  #   obj.upon(:A, true) { puts '1st executed' }    #=> obj
  #   obj.upon(:A, true) { puts '2nd executed' }    #=> obj
  #   obj.upon(:A)       { puts '3rd executed' }    #=> obj
  #   
  #   obj.ignore(:A)                                #=> obj
  #   obj.fire(:A)                                  #=> obj
  # 
  # produces:
  # 
  #   1st executed
  #   2nd executed
  # 
  # The second form takes a hash of +Proc+ objects keyed by event name,
  # running <tt>obj.upon(name, &proc)</tt> on each key-value pair, then
  # returns _obj_.
  # 
  #   proc_1 = Proc.new { puts '1st executed' }   #=> #<Proc:0x3e78ee>
  #   proc_2 = Proc.new { puts '2nd executed' }   #=> #<Proc:0x3e888a>
  #   
  #   obj.upon(:A => proc_1, :B => proc_2)        #=> obj
  #   obj.fire(:B)                                #=> obj
  # 
  # produces
  # 
  #   2nd executed
  # 
  def upon(sym_or_hash, unignorable, &block)
    if sym_or_hash.instance_of?(Hash)
      sym_or_hash.each {|name,proc| self.upon(name, &proc) }
      return self
    else
      name = sym_or_hash.to_sym
      @code_events       ||= {}
      @code_events[name] ||= []
      @code_events[name] << block
      `block.__block__.__unignorable__=typeof(unignorable)=='function'?false:unignorable`
      return self
    end
  end
end
