# A wrapper class for the browser's built-in event objects.
class Event
  KEYS = {
    :enter => 13,
  	:up => 38,
  	:down => 40,
  	:left => 37,
  	:right => 39,
  	:esc => 27,
  	:space => 32,
  	:backspace => 8,
  	:tab => 9,
  	:delete => 46
  }
  
  attr :event, :type, :page, :client, :right_click, 
       :wheel, :related_target, :target, :code, :key,
       :shift, :control, :alt, :meta
  
  def initialize(event, win = nil)
    # normalize the reference the window object
    win = win || window
    
    # normalize the reference to the document object
    doc = win[:document]
    
    # normalize the reference to the native event object
    native_event = event || win[:event]
    
    # return if this event has already been extended
    return if @extended
    
    # otherwise, we'll get here. extend the native object
    @extended = true
    
    type = native_event[:type]
    target = native_event[:target] || native_event[:srcElement]
    
    while (target && target[:nodeType] == 3)
      target = native_event[:parentNode]
    end
    
    if type.match(/key/)
     code = native_event[:which] || native_event[:keyCode]
     key = Event::Keys.index(code)
    elsif type.match(/(click|mouse|menu)/i)
      doc = (!doc[:compatMode] || doc[:compatMode] == 'CSS1Compat') ? doc[:html] : doc[:body]
      page = {
				:x => native_event[:pageX] || native_event[:clientX] + doc[:scrollLeft],
				:y => native_event[:pageY] || native_event[:clientY] + docs[:scrollTop]
  		}
  		client = {
  		  :x => native_event[:pageX] ? native_event[:pageX] - win[:pageXOffset] : native_event[:clientX],
				:y => native_event[:pageY] ? native_event[:pageY] - win[:pageYOffset] : native_event[:clientY]
  		}
  		
  		# check to see if the mouse event was a mouse scrolling event, normalizing for browser differences
  		if type.match(/DOMMouseScroll|mousewheel/)
  		  wheel = native_event[:wheelDelta] ? native_event[:wheelDelta] / 120 : -(native_event[:detail] || 0) / 3
		  end
		  
		  right_click = native_event[:which] == 3 || native_event[:button] == 2
		  related = nil
		  
		  # check to see if the mouse event was mouseover or mouseout, normalizing for browser differences
		  if type.match(/over|out/)
		    case type
		    when 'mouseover'
		      related = native_event[:relatedTarget] || native_event[:fromElement]
		      break
	      when 'mouseout'
	        related = native_event[:relatedTarget] || native_event[:toElement]
		    end
		  end
    
      # assign local vars to instance variables. 
      # We use local vars initially because of javascript ineffciency
      # in accessing its slots.
      @native_event = native_event
      @type = type
      @page = page
      @client = client
      @right_click = right_click
      @wheel = wheel
      @related_target = related
      @target = target
      @code = code
      @key = key
      @shift = native_event[:shiftKey]
      @control = native_event[:ctrlKey]
      @alt = native_event[:altKey]
      @meta = native_event[:metaKey]
    end
  end
  
  def stop!
    self.stop_propagation.preventDefault
  end
  
  # Calls either stopPropagation or sets cancelBubble to false on the native event object, depending on browser
  def stop_propagation
    @native_event[:stopPropagation] ?  @native_event[:stopPropagation] : @native_event[:cancelBubble] = true
		return self
  end
  
  # Calls either preventDefault or sets returnValue to false on the native event object, depending on browser
  def prevent_default
    @native_event[:preventDefault] ? @native_event[:preventDefault] : @native_event[:returnValue] = false
    return self
  end
end