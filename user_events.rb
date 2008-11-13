require 'document'
require 'element'
require 'event'

# The +UserEvents+ module mixes in methods for handling user-generated events
# such as mouse gestures and keystrokes. +UserEvents+ is also responsible for
# defining new event types based on native events.
# 
# Only +Document+, +Window+, and objects of class +Element+ respond to
# +UserEvents+ methods. See module +CodeEvents+ for information on defining
# and handling custom callback events.
# 
module UserEvents
  `c$UserEvents.mousecheck=function(element,event){
    var related=event.__related_target__,el=element.__native__;
    if(related===nil||related==undefined){return true;};
    if(related===false){return false;};
    return((el!==document)&&(related!=el)&&(related.prefix!='xul')&&!(el.contains?el.contains(related):!!(el.compareDocumentPosition(el)&16)))
  }`
  
  NATIVE_EVENTS = {
  # mouse buttons
    :click            => 2,
    :dblclick         => 2,
    :mouseup          => 2,
    :mousedown        => 2,
    :contextmenu      => 2,
  # mouse wheel
    :mousewheel       => 2,
    :DOMMouseScroll   => 2,
  # mouse movement
    :mouseover        => 2,
    :mouseout         => 2,
    :mousemove        => 2,
    :selectstart      => 2,
    :selectend        => 2,
  # keyboard
    :keydown          => 2,
    :keypress         => 2,
    :keyup            => 2,
  # form elements
    :focus            => 2,
    :blur             => 2,
    :change           => 2,
    :reset            => 2,
    :select           => 2,
    :submit           => 2,
  # window
    :load             => 1,
    :unload           => 1,
    :beforeunload     => 1,
    :resize           => 1,
    :move             => 1,
    :DOMContentLoaded => 1,
    :readystatechange => 1,
  # misc
    :error            => 1,
    :abort            => 1,
    :scroll           => 1
  }
  
  DEFINED_EVENTS = {
    :mouse_enter => {:base => 'mouseover', :condition => proc(`c$UserEvents.mousecheck`) },
    :mouse_leave => {:base => 'mouseout',  :condition => proc(`c$UserEvents.mousecheck`) },
    :mouse_wheel => {:base => gecko? ? 'DOMMouseScroll' : 'mousewheel' }
  }
  
  # call-seq:
  #   UserEvents.define(sym, { :base => symbol [, ...] }) -> true
  # 
  # Adds a new event type _sym_ to the UserEvents::DEFINED_EVENTS hash with
  # the given options. The following options can be set:
  # 
  # *Required*
  # <i>base</i>::        A symbol representing the native event type upon
  #                      which _sym_ will be based.
  # 
  # *Optional*
  # <i>condition</i>::   A +Proc+ object with parameters
  #                      <tt>|element, event|</tt> which, if returning +false+
  #                      when evaluated for a given event, kills the event.
  # <i>on_listen</i>::   A +Proc+ object with parameters
  #                      <tt>|element, listener_proc|</tt> that is evaluated
  #                      when _sym_ is passed to <tt>UserEvents#listen</tt>.
  # <i>on_unlisten</i>:: A +Proc+ object with parameters
  #                      <tt>|element, listener_proc|</tt> that is evaluated
  #                      when _sym_ is passed to <tt>UserEvents#unlisten</tt>.
  # 
  # --------------------------------------------------------------------------
  # 
  #   condition = proc {|element,event| event.shift? }                                                                            #=> #<Proc:0x393825>
  #   on_listen = proc {|element,listener_proc| puts "%s responds to shift-click with %s" % [element.inspect, listener_proc] }    #=> #<Proc:0x3935da>
  #   
  #   UserEvents.define(:shift_click, :base => 'click', :condition => condition, :on_listen => on_listen)                         #=> true
  #   
  #   Document['#example'].listen :shift_click do |element,event|
  #     puts "%s was shift-clicked" % element.inspect
  #   end
  # 
  # produces:
  # 
  #   #<Element: DIV id="example"> responds to shift-click with #<Proc:0x3962ae>
  # 
  # shift-clicking element '#example' produces:
  # 
  #   #<Element: DIV id="example"> was shift-clicked
  # 
  def self.define(sym, hash = {})
    DEFINED_EVENTS[sym.to_sym] = hash
    return true
  end
  
  def self.included(base) # :nodoc:
    raise(TypeError, 'only class Element and the singleton objects Window and Document may include UserEvents; use CodeEvents instead') unless base == ::Element
  end
  
  def self.extended(base) # :nodoc:
    raise(TypeError, 'only Document and Window may be extended with UserEvents; use CodeEvents instead') unless [Document, Window].include?(base)
  end
  
  # call-seq:
  #   obj.listen(sym) { |element,event| block } -> obj
  # 
  # Adds a listener to _obj_ for a native or defined user event type _sym_,
  # then returns _obj_.
  # 
  #   Document['#example'].listen :click do |element, event|
  #     puts "%s was clicked" % element.inspect
  #   end
  # 
  # clicking element '#example' produces:
  # 
  #   #<Element: DIV id="example"> was clicked
  # 
  def listen(sym, &block)
    type = sym.to_sym
    events = @events ||= {}
    events[type]     ||= {}
    return self if events[type][block]
    
    custom    = DEFINED_EVENTS[type]
    condition = block
    real_type = type
    
    if custom
      custom[:on_listen].call(self, block) if custom[:on_listen]
      if custom[:condition]
        condition = lambda {|element,event| custom[:condition].call(element,event) ? block.call(element,event) : true }
      end
      real_type = (custom[:base] || real_type).to_sym
    end
    
    listener     = lambda { block.call(self,nil); }
    native_event = NATIVE_EVENTS[real_type]
    
    if native_event
      if native_event == 2
        listener = lambda do |native_event|
          event = `$v(native_event)`
          event.kill! if condition.call(self,event) == false
        end
      end
      self.add_listener(real_type, &listener)
    end
    
    events[type][block] = listener
    return self
  end
  
  def add_listener(sym, &block) # :nodoc:
    `var el=this.__native__,type=sym.__value__,fn=block.__block__`
    `if(type==='unload'){var old=fn,that=this;fn=function(){that.m$remove_listener($q('unload'),fn);old();};}else{var collected = {};collected[this.__id__]=this}` # TODO: put this element into "collected"
    `if(el.addEventListener){el.addEventListener(type,fn,false);}else{el.attachEvent('on'+type,fn);}`
    return self
  end
  
  # call-seq:
  #   obj.unlisten(sym, &proc) -> obj
  # 
  # Unsets the function _proc_ as a listener for event type _sym_, then
  # returns _obj_. _proc_ must be the self-same object originally assigned as
  # a listener.
  # 
  #   proc_1 = proc {|element,event| puts "%s was clicked" % element.inspect }
  #   proc_2 = proc {|element,event| puts "%s has two listeners" % element.inspect }
  #   elem = Document['#example']
  #   
  #   elem.listen(:click, proc_1).listen(:click, proc_2)    #=> #<Element: DIV id="example">
  #   elem.unlisten(:click, proc_2)                         #=> #<Element: DIV id="example">
  # 
  # clicking element '#example' produces:
  # 
  #   #<Element: DIV id="example"> was clicked
  # 
  def unlisten(sym, &block)
    type   = sym.to_sym
    events = @events
    return self unless events && events[type] && events[type][block]
    
    listener = events[type].delete(block)
    custom   = DEFINED_EVENTS[type]
    
    if custom
      custom[:on_unlisten].call(self, block) if custom[:on_unlisten]
      type = (custom[:base] || type).to_sym
    end
    
    self.remove_listener(type, &listener) if NATIVE_EVENTS[type]
    return self
  end
  
  def remove_listener(sym, &block) # :nodoc:
    `var el=this.__native__,type=sym.__value__,fn=block.__block__`
    `if(this.removeEventListener){this.removeEventListener(type,fn,false);}else{this.detachEvent('on'+type,fn);}`
    return self
  end
end

module ::Document
  extend UserEvents
end
