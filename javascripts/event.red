`function $v(event){
  var doc=$u,result=$u,type=$u,target=$u,code=$u,key=$u,f_key=$u,wheel=$u,right_click=$u,page=$u,client=$u,related_target=$u;
  event = event || window.event;
  doc = document;
  if(!event){return nil;};
  result=c$Event.m$new(null);
  type = event.type;
  target = event.target || event.srcElement;
  while(target&&target.nodeType==3){target=event.parentNode;};
  if(/key/.test(type)){
    code=event.which || event.keyCode;
    key=c$Event.c$KEYS.m$_brac(code);
    if(type=='keydown'){f_key=code-111;if(f_key>0&&f_key<13){key=$s('f'+f_key);};};
    key=$T(key)?key:$s(String.fromCharCode(code).toLowerCase());
  }else{
    if(type.match(/(click|mouse|menu)/i)){
      doc=(!doc.compatMode || doc.compatMode == 'CSS1Compat') ? doc.html : doc.body;
      wheel=(type.match(/DOMMouseScroll|mousewheel/) ? (event.wheelDelta ? event.wheelDelta/120 : -(event.detail||0) / 3) : nil);
      right_click=event.which==3||event.button==2;
      page={x:(event.pageX || event.clientX + doc.scrollLeft),y:(event.pageY || event.clientY + doc.scrollTop)};
      client={x:(event.pageX ? event.pageX - window.pageXOffset : event.clientX),y:(event.pageY ? event.pageY - window.pageYOffset : event.clientY)};
      if(type.match(/over|out/)){
        switch(type){
          case 'mouseover':related_target=event.relatedTarget || event.fromElement;break;
          case 'mouseout':related_target=event.relatedTarget || event.toElement;break;
        };
        if(window.m$gecko_bool()){
          try{while(related_target&&related_target.nodeType==3){related_target=related_target.parentNode;};}catch(e){related_target=false;};
        }else{while(related_target&&related_target.nodeType==3){related_target.parentNode;};};
      };
    };
  };
  result.__native__=event;result.__code__=code;result.__key__=key;result.__type__=type;result.__target__=target;result.__wheel__=wheel;result.__right_click__=right_click;result.__related_target__=related_target;
  result.__page__=page||{x:nil,y:nil};result.__client__=client||{x:nil,y:nil};
  result.__shift__=event.shiftKey;result.__ctrl__=event.ctrlKey;result.__alt__=event.altKey;result.__meta__=event.metaKey;
  return result;
}`

# A wrapper class for the browser's built-in event objects.
class Event
  KEYS = {
    8  => :backspace,
    9  => :tab,
    13 => :enter,
    27 => :esc,
    32 => :space,
    37 => :left,
    38 => :up,
    39 => :right,
    40 => :down,
    46 => :delete
  }
  
  # call-seq:
  #   evnt.alt? -> true or false
  # 
  # Returns +true+ if the alt key was depressed during the event, +false+
  # otherwise.
  # 
  def alt?
    `this.__alt__`
  end
  
  # call-seq:
  #   evnt.base_type -> symbol
  # 
  # Returns a symbol representing _evnt_'s event type, or +:base+ type if
  # _evnt_ is a defined event.
  # 
  def base_type
    `$s(this.__type__)`
  end
  
  # call-seq:
  #   evnt.client -> hash
  # 
  # Returns a hash keyed by <tt>:x<tt> and <tt>:y</tt>, which represent
  # _evnt_'s distance in pixels from the left and top edges of the browser
  # viewport.
  # 
  def client
    {:x => `this.__client__.x`, :y => `this.__client__.y`}
  end
  
  # call-seq:
  #   evnt.code -> integer or nil
  # 
  # If _evnt_ involved a keystroke, returns the ASCII code of the key pressed,
  # otherwise returns +nil+.
  # 
  def code
    `this.__code__ || nil`
  end
  
  # call-seq:
  #   evnt.ctrl? -> true or false
  # 
  # Returns +true+ if the control key was depressed during the event, +false+
  # otherwise.
  # 
  def ctrl?
    `this.__ctrl__`
  end
  
  # call-seq:
  #   evnt.key -> symbol or nil
  # 
  # If _evnt_ involved a keystroke, returns a symbol representing the key
  # pressed, otherwise returns +nil+.
  # 
  def key
    `this.__key__ || nil`
  end
  
  # call-seq:
  #   evnt.kill! -> evnt
  # 
  # Stops the event in place, preventing the default action as well as any
  # further propagation, then returns _evnt_.
  # 
  def kill!
    self.stop_propagation.prevent_default
  end
  
  # call-seq:
  #   evnt.meta? -> true or false
  # 
  # Returns +true+ if the meta key was depressed during the event, +false+
  # otherwise.
  # 
  def meta?
    `this.__meta__`
  end
  
  # call-seq:
  #   evnt.page -> hash
  # 
  # Returns a hash keyed by <tt>:x<tt> and <tt>:y</tt>, which represent
  # _evnt_'s distance in pixels from the left and top edges of the current
  # page, including pixels that may have scrolled out of view.
  # 
  def page
    {:x => `this.__page__.x`, :y => `this.__page__.y`}
  end
  
  # call-seq:
  #   evnt.prevent_default -> evnt
  # 
  # Instructs the event to abandon its default browser action, then returns
  # _evnt_.
  # 
  def prevent_default
    native = `this.__native__`
    `native.preventDefault?native.preventDefault():native.returnValue=false`
    return self
  end
  
  # call-seq:
  #   evnt.right_click? -> true or false
  # 
  # Returns +true+ if the event was a right click.
  # 
  def right_click?
    `this.__right_click__`
  end
  
  # call-seq:
  #   evnt.shift? -> true or false
  # 
  # Returns +true+ if the shift key was depressed during the event, +false+
  # otherwise.
  # 
  def shift?
    `this.__shift__`
  end
  
  # call-seq:
  #   evnt.stop_propagation -> evnt
  # 
  # Instructs the event to stop propagating, then returns _evnt_.
  # 
  def stop_propagation
    native = `this.__native__`
    `native.stopPropagation?native.stopPropagation():native.cancelBubble=true`
    return self
  end
  
  # call-seq:
  #   evnt.target -> element
  # 
  # Returns the DOM element targeted by _evnt_, or +nil+ if no element was
  # targeted.
  # 
  def target
    `$E(this.__target__)`
  end
  
  # call-seq:
  #   evnt.wheel -> numeric or nil
  # 
  # Returns a floating point number representing the number of wheel
  # "revolutions" executed during _evnt_. Positive values indicate upward
  # scrolling, negative values indicate downward scrolling. Returns +nil+ if
  #∑ _evnt_ did not involve the mouse wheel.
  # 
  def wheel
    `this.__wheel__`
  end
end