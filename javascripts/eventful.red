# Module +Eventful+ mixes in methods for handling custom events.
# 
module Eventful
  # call-seq:
  #   eventful.fire(sym)                  -> eventful
  #   eventful.fire(sym, delay, arg, ...) -> eventful
  # 
  # Instructs _eventful_ to call the +Proc+ objects associated with the event
  # _sym_, then returns _eventful_. Optionally delays the firing of the event
  # by _delay_ milliseconds. The second form allows passing of arguments to
  # the event's +Proc+ objects, but if any arguments are passed, the first
  # must be the _delay_ argument.
  # 
  #   eventful.listen(:A) {|x| puts x }       #=> eventful
  #   eventful.listen(:B) {|y| puts y }       #=> eventful
  #   eventful.listen(:C) { puts 'fire 3' }   #=> eventful
  #   
  #   eventful.fire(:A, 500, 'fire 1').fire(:B, 0, 'fire 2').fire(:C)
  # 
  # produces:
  # 
  #   fire 2
  #   fire 3
  #   fire 1
  # 
  def fire(sym, delay, *args)
    name = sym.to_sym
    return self unless @events && events_group = @events[name]
    events_group.each {|proc| proc.process_event(self, delay, args) }
    return self
  end
  
  # call-seq:
  #   eventful.ignore             -> eventful
  #   eventful.ignore(sym)        -> eventful
  #   eventful.ignore(sym, &proc) -> eventful
  # 
  # Instructs _eventful_ to ignore the specified event, then returns
  # _eventful_.
  # 
  # In the first form, all event-related +Proc+ objects not marked
  # as "unignorable" are removed from _eventful_.
  # 
  #   eventful.listen(:A, true) { puts '1st executed' }   #=> eventful
  #   eventful.listen(:A)       { puts '2nd executed' }   #=> eventful
  #   eventful.listen(:B)       { puts '3rd executed' }   #=> eventful
  #   
  #   eventful.ignore                                     #=> eventful
  #   eventful.fire(:A).fire(:B)                          #=> eventful
  # 
  # produces:
  # 
  #   1st executed
  # 
  # In the second form, only the ignorable +Proc+ objects associated with the
  # event _sym_ are removed.
  # 
  #   eventful.listen(:A, true) { puts '1st executed' }   #=> eventful
  #   eventful.listen(:A)       { puts '2nd executed' }   #=> eventful
  #   eventful.listen(:B)       { puts '3rd executed' }   #=> eventful
  #   
  #   eventful.ignore(:A)                                 #=> eventful
  #   eventful.fire(:A).fire(:B)                          #=> eventful
  # 
  # produces:
  # 
  #   1st executed
  #   3rd executed
  # 
  # In the third form, only the +Proc+ object passed in as <i>&proc</i> is
  # removed.
  # 
  #   block_1 = Proc.new { puts '1st executed' }    #=> #<Proc:0x3e78ee>
  #   block_2 = Proc.new { puts '2nd executed' }    #=> #<Proc:0x3e888a>
  #   
  #   eventful.listen(:A, &block_1)                 #=> eventful
  #   eventful.listen(:A, &block_2)                 #=> eventful
  #   
  #   eventful.ignore(:A, &block_1)                 #=> eventful
  #   eventful.fire(:A)                             #=> eventful
  # 
  # produces:
  # 
  #   2nd executed
  # 
  def ignore(sym, &block)
    if sym
      name = sym.to_sym
      return self unless @events && events_group = @events[name]
      if block
        events_group.delete(block) unless `block.__block__.__unignorable__`
      else
        events_group.each {|proc| self.ignore(name, &proc) }
      end
    else
      @events.each_key {|name| self.ignore(name) }
    end
    return self
  end
  
  # call-seq:
  #   eventful.listen(sym, unignorable = false) { |arg,...| block } -> eventful
  #   eventful.listen(hash)                                         -> eventful
  # 
  # Stores a number of +Proc+ objects to be called when the event _sym_ is
  # fired.
  # 
  # The first form adds _block_ to the array of +Proc+ objects executed when
  # the event _sym_ is fired, then returns _eventful_. If _unignorable_ is set
  # to +true+, the _block_ will be executed when _sym_ fires, regardless of
  # whether it has been ignored.
  # 
  #   eventful.listen(:A, true) { puts '1st executed' }   #=> eventful
  #   eventful.listen(:A, true) { puts '2nd executed' }   #=> eventful
  #   eventful.listen(:A)       { puts '3rd executed' }   #=> eventful
  #   
  #   eventful.ignore(:A)                                 #=> eventful
  #   eventful.fire(:A)                                   #=> eventful
  # 
  # produces:
  # 
  #   1st executed
  #   2nd executed
  # 
  # The second form takes a hash of +Proc+ objects keyed by event name,
  # running <tt>eventful.listen(name, &proc)</tt> on each key-value pair, then
  # returns _eventful_.
  # 
  #   block_1 = Proc.new { puts '1st executed' }      #=> #<Proc:0x3e78ee>
  #   block_2 = Proc.new { puts '2nd executed' }      #=> #<Proc:0x3e888a>
  #   
  #   eventful.listen(:A => block_1, :B => block_2)   #=> eventful
  #   eventful.fire(:B)                               #=> eventful
  # 
  # produces
  # 
  #   2nd executed
  # 
  def listen(sym_or_hash, unignorable, &block)
    if sym_or_hash.instance_of?(Hash)
      sym_or_hash.each {|name,proc| self.listen(name, &proc) }
      return self
    else
      name = sym_or_hash.to_sym
      @events       ||= {}
      @events[name] ||= []
      @events[name] << block
      `block.__block__.__unignorable__=typeof(unignorable)=='function'?false:unignorable`
      return self
    end
  end
  
  class ::Proc
    def process_event(context, delay, args_array)
      `var f=this.__block__.__unbound__,eventFunction=function(){return f.apply(context,argsArray);}`
      `if(delay){return setTimeout(eventFunction,delay);}`
      `eventFunction()`
    end
  end
end
