``

# A wrapper class for the browser's built-in event objects.
class Event
  KEYS = {
    8   => :backspace,
    9,  => :tab,
    13, => :enter,
    27, => :esc,
    32, => :space,
    37, => :left,
    38, => :up
    39, => :right,
    40, => :down,
    46, => :delete,
  }
  
  def initialize(event)
    win = `window`
    doc = `win.document`
    native_event = event || `win.event`
    `this.__native__=nativeEvent`
    
    type   = `$q(nativeEvent.type)`
    target = `nativeEvent.target || nativeEvent.srcElement`
    while (`target && target.nodeType == 3`) { `target = nativeEvent.parentNode` }
    
    if `type.__value__.test(/key/)`
      code = `nativeEvent.which || nativeEvent.keyCode`
      key = KEYS[code]
      if type == 'keydown'
        f_key = `code-111`
        key = `$s('f'+fKey)` if `fKey>0&&fKey<13`
      end
      key = `key==nil?$s(String.fromCharCode(code).toLowerCase()):key`
    elsif `type.__value__.match(/(click|mouse|menu)/i)`
      doc         = `(!doc.compatMode || doc.compatMode == 'CSS1Compat') ? doc.html : doc.body`
      wheel       = `type.__value__.match(/DOMMouseScroll|mousewheel/)` ? `nativeEvent.wheelDelta ? nativeEvent.wheelDelta / 120 : -(nativeEvent.detail || 0) / 3` : nil
      right_click = `nativeEvent.which == 3 || nativeEvent.button == 2`
      page        = { :x => `nativeEvent.pageX || nativeEvent.clientX + doc.scrollLeft`,
                      :y => `nativeEvent.pageY || nativeEvent.clientY + doc.scrollTop` }
      client      = { :x => `nativeEvent.pageX ? nativeEvent.pageX - win.pageXOffset : nativeEvent.clientX`,
                      :y => `nativeEvent.pageY ? nativeEvent.pageY - win.pageYOffset : nativeEvent.clientY` }
      if `type.__value__.match(/over|out/)`
        case type
          when 'mouseover' : related_target = `nativeEvent.relatedTarget || nativeEvent.fromElement`
          when 'mouseout'  : related_target = `nativeEvent.relatedTarget || nativeEvent.toElement`
        end
        if gecko?
          `try{while(relatedTarget&&relatedTarget.nodeType==3){relatedTarget=relatedTarget.parentNode;};}catch(e){relatedTarget=false;}`
        else
          `while(relatedTarget&&relatedTarget.nodeType==3){relatedTarget=relatedTarget.parentNode;}`
        end
      end
    end
    
    @code           = code           || nil
    @key            = key            || nil
    @type           = type           || nil
    @target         = target         || nil
    @wheel          = wheel          || nil
    @right_click    = right_click    || false
    @related_target = related_target || false
    @page           = page           || {:x => nil, :y => nil}
    @client         = client         || {:x => nil, :y => nil}
    @shift          = `nativeEvent.shiftKey`
    @control        = `nativeEvent.ctrlKey`
    @alt            = `nativeEvent.altKey`
    @meta           = `nativeEvent.metaKey`
  end
  
  attr :event, :type, :page, :client,
       :related_target, :target, :code, :key
  
  # call-seq:
  #   evnt.alt? -> true or false
  # 
  # Returns +true+ if the alt key was depressed during the event, +false+
  # otherwise.
  # 
  def alt?
    @alt
  end
  
  # call-seq:
  #   evnt.circumvent -> evnt
  # 
  # Instructs the event to abandon its default browser action, then returns
  # _evnt_.
  # 
  def circumvent
    native = `this.__native__`
    `native.preventDefault?native.preventDefault():native.returnValue=false`
    return self
  end
  
  # call-seq:
  #   evnt.client -> hash
  # 
  # Returns a hash keyed by <tt>:x<tt> and <tt>:y</tt>, which represent
  # _evnt_'s distance in pixels from the left and top edges of the browser
  # viewport.
  # 
  def client
    @client
  end
  
  # call-seq:
  #   evnt.control? -> true or false
  # 
  # Returns +true+ if the control key was depressed during the event, +false+
  # otherwise.
  # 
  def control?
    @control
  end
  
  # call-seq:
  #   evnt.kill! -> evnt
  # 
  # Stops the event in place, preventing the original action as well as any
  # further propagation, then returns _evnt_.
  # 
  def kill!
    self.stop_propagation.circumvent
  end
  
  # call-seq:
  #   evnt.meta? -> true or false
  # 
  # Returns +true+ if the meta key was depressed during the event, +false+
  # otherwise.
  # 
  def meta?
    @meta
  end
  
  # call-seq:
  #   evnt.page -> hash
  # 
  # Returns a hash keyed by <tt>:x<tt> and <tt>:y</tt>, which represent
  # _evnt_'s distance in pixels from the left and top edges of the current
  # page, including pixels that may have scrolled out of view.
  # 
  def page
    @page
  end
  
  # call-seq:
  #   evnt.right_click? -> true or false
  # 
  # Returns +true+ if the event was a right click.
  # 
  def right_click?
    @right_click
  end
  
  # call-seq:
  #   evnt.shift? -> true or false
  # 
  # Returns +true+ if the shift key was depressed during the event, +false+
  # otherwise.
  # 
  def shift?
    @shift
  end
  
  # call-seq:
  #   evnt.stop_propagation
  # 
  # Instructs the event to stop propagating, then returns _evnt_.
  # 
  def stop_propagation
    native = `this.__native__`
    `native.stopPropagation?native.stopPropagation():native.cancelBubble=true`
    return self
  end
  
  # call-seq:
  #   evnt.wheel? -> numeric or nil
  # 
  # Returns something.
  # 
  def wheel
    @wheel
  end
end