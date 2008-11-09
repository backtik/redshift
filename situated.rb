require 'element'
require 'window'

module Situated # :nodoc:
  `window.styleString=function(el,prop){if(el.currentStyle){return el.currentStyle[prop.replace(/[_-]\\D/g, function(match){return match.charAt(1).toUpperCase();})];};var computed=document.defaultView.getComputedStyle(el,null);return(computed?computed.getPropertyValue([prop.replace(/[A-Z]/g, function(match){return('-'+match.charAt(0).toLowerCase());})]):null);}`
  
  # Module <tt>Situated::PositionAndSize</tt> mixes in convenience methods for
  # finding height/width and vertical/horizontal position, with and without
  # scrolling factored in.
  # 
  module PositionAndSize
    # call-seq:
    #   obj.height -> integer
    # 
    # Returns _obj_'s height in pixels, including any padding or borders.
    # Equivalent to <tt>obj.size[:y]</tt>.
    # 
    #   <div id="example" style="height:200px;padding:10px 0;border:1px solid #CC0404"></div>
    #   
    #   Document['#example'].height   #=> 222
    # 
    def height
      self.size[:y]
    end
    
    # call-seq:
    #   obj.left -> integer
    # 
    # Returns _obj_'s distance in pixels from the left edge of the current
    # page, including any pixels that may have scrolled out of view.
    # Equivalent to <tt>obj.position[:x]</tt>.
    # 
    #   <body style="margin:0">
    #     <div id="example" style="margin:50px"></div>
    #   </body>
    #   
    #   Document['#example'].left   #=> 50
    # 
    def left
      self.position[:x]
    end
    
    # call-seq:
    #   obj.scroll_width -> integer
    # 
    # Returns the total height in pixels inside _obj_, including any portions
    # that may have scrolled out of view, but excluding the height of the
    # scroll bar and any padding or borders. Equivalent to
    # <tt>obj.scroll_size[:y]</tt>.
    # 
    #   <textarea id="example">
    #     1
    #     2
    #     3
    #     4
    #   </textarea>
    #   
    #   Document['#example'].scroll_height   #=> 70
    # 
    def scroll_height
      self.scroll_size[:y]
    end
    
    # call-seq:
    #   obj.scroll_left -> integer
    # 
    # Returns the number of pixels to the left that have been scrolled out of
    # view inside _obj_. Equivalent to <tt>obj.scroll[:x]</tt>.
    # 
    #   <textarea id="example">123456789012345678901234567890</textarea>    ## (scrolled to the right)
    #   
    #   Document['#example'].scroll_left    #=> 62
    # 
    def scroll_left
      self.scroll[:x]
    end
    
    # call-seq:
    #   obj.scroll_top -> integer
    # 
    # Returns the number of pixels at the top of the area inside _obj_ that
    # have been scrolled out of view. Equivalent to <tt>obj.scroll[:y]</tt>.
    # 
    #   <textarea id="example">   ## (scrolled to the bottom)
    #     1
    #     2
    #     3
    #     4
    #   </textarea>
    #   
    #   Document['#example'].scroll_top    #=> 27
    # 
    def scroll_top
      self.scroll[:y]
    end
    
    # call-seq:
    #   obj.scroll_width -> integer
    # 
    # Returns the total width in pixels inside _obj_, including any portions
    # that may have scrolled out of view, but excluding the width of the
    # scroll bar and any padding or borders. Equivalent to
    # <tt>obj.scroll_size[:x]</tt>.
    # 
    #   <textarea id="example">123456789012345678901234567890</textarea>
    #   
    #   Document['#example'].scroll_width   #=> 235
    # 
    def scroll_width
      self.scroll_size[:x]
    end
    
    # call-seq:
    #   obj.top -> integer
    # 
    # Returns _obj_'s distance in pixels from the top edge of the current
    # page, including any pixels that may have scrolled out of view.
    # Equivalent to <tt>obj.position[:y]</tt>.
    # 
    #   <body style="margin:0">
    #     <div id="example" style="margin:50px"></div>
    #   </body>
    #   
    #   Document['#example'].top    #=> 50
    # 
    def top
      self.position[:y]
    end
    
    # call-seq:
    #   obj.width -> integer
    # 
    # Returns _obj_'s width in pixels, including any padding or borders.
    # Equivalent to <tt>obj.size[:x]</tt>.
    # 
    #   <div id="example" style="width:200px;padding:0 10px;border:1px solid #CC0404"></div>
    #   
    #   Document['#example'].width    #=> 222
    # 
    def width
      self.size[:x]
    end
  end
  
  # Module <tt>Situated::Element</tt> provides the methods used by +Element+
  # objects when calling the methods in +PositionAndSize+, as well as the
  # element manipulation methods <tt>scroll_to</tt> and <tt>position_at</tt>.
  # 
  module Situated::Element
    include PositionAndSize
    
    # call-seq:
    #   elem.offset_parent -> element or nil
    # 
    # Returns _elem_'s nearest positioned ancestor element, or +nil+ if no
    # such element exists.
    # 
    #   <div id="example" style="width:100px;height:100px;position:relative">
    #     <div id="inner" style="width:10px;height:10px"></div>
    #   </div>
    #   
    #   Document['#inner'].offset_parent      #=> #<Element: DIV id="example">
    #   Document['#example'].offset_parent    #=> #<Element: BODY>
    #   Document.body.offset_parent           #=> nil
    # 
    def offset_parent
      return nil if self.is_body?
      
      native_element = `this.__native__`
      return `$E(native_element.offsetParent)` unless trident?
      
      while (element = `$E(native_element.parentNode)`) && !element.is_body? do
        return element unless element.styles[:position] == 'static'
      end
      
      return nil
    end
    
    def offsets # :nodoc:
      native_element = `this.__native__`
      
      if trident?
        `var bound=native_element.getBoundingClientRect(),html=this.m$document().__native__.documentElement`
        return {:x => `bound.left+html.scrollLeft-html.clientLeft`,:y => `bound.top+html.scrollTop-html.clientTop`}
      end
      
      return {:x => 0, :y => 0} if self.is_body?
      
      x = 0
      y = 0
      u = Situated::Utilities
      element = native_element
      `while (element && !u.m$is_body_bool(element)){
        x+=element.offsetLeft;y+=element.offsetTop;
        if (m$gecko_bool()){
          if (!u.m$border_box(element)){x+=u.m$left_border(element);y+=u.m$top_border(element);};
          var parent = element.parentNode;
          if (parent && window.styleString(parent, 'overflow') != 'visible'){ x += u.m$left_border(parent); y += u.m$top_border(parent); };
        } else { if (element != this && m$webkit_bool()){ x += u.m$left_border(element); y += u.m$top_border(element); }; };
        element = element.offsetParent;
      }`
      
      if gecko? && !u.border_box(native_element)
        x -= u.left_border(native_element)
        y -= u.top_border(native_element)
      end
      
      return {:x => x, :y => y}
    end
    
    # call-seq:
    #   elem.position          -> {:x => integer, :y => integer}
    #   elem.position(element) -> {:x => integer, :y => integer}
    # 
    # Returns a hash containing the horizontal (_x_) and vertical (_y_)
    # positions of _elem_ in pixels.
    # 
    # In the first form, the positions returned are relative to the viewport,
    # and in the second form, they are relative to _element_.
    # 
    #   <div id="example" style="width:100px;height:100px">
    #     <div id="inner" style="width:10px;height:10px"></div>
    #   </div>
    #   
    #   Document['#example'].position                       #=> {:x => 50, :y => 50}
    #   Document['#inner'].position                         #=> {:x => 50, :y => 50}
    #   Document['#inner'].position(Document['#example'])   #=> {:x => 0, :y => 0}
    # 
    def position(relative_to = nil)
      return {:x => 0, :y => 0} if self.is_body?
      offset = self.offsets
      scroll = self.scrolls
      relative_position = relative_to ? relative_to.position : {:x => 0, :y => 0}
      x = offset[:x] - scroll[:x] - relative_position[:x]
      y = offset[:y] - scroll[:y] - relative_position[:y]
      return {:x => x, :y => y}
    end
    
    # call-seq:
    #   elem.position_at(x,y) -> elem
    # 
    # Repositions _elem_ so that its top left corner is at the point _x_
    # (horizontal) pixels and _y_ (vertical) pixels from the top left corner
    # of the area inside _elem_'s most recent absolutely-positioned ancestor,
    # then returns _elem_.
    # 
    #   <div id="example" style="width:100px;height:100px">
    #     <div id="inner" style="width:10px;height:10px"></div>
    #   </div>
    #   
    #   Document['#example'].position_at(100,100).position    #=> {:x => 100, :y => 100}
    #   Document['#inner'].position_at(25,35).position        #=> {:x => 125, :y => 135}
    # 
    def position_at(x,y)
      u = Situated::Utilities
      native_element = `this.__native__`
      left = x - u.styleNumber(native_element, `'margin-left'`)
      top  = y - u.styleNumber(native_element, `'margin-top'`)
      self.set_styles(:left => left, :top => top, :position => 'absolute')
    end
    
    # call-seq:
    #   elem.scroll -> {:x => integer, :y => integer}
    # 
    # Returns a hash containing the horizontal (_x_) and vertical (_y_)
    # distance scrolled in pixels inside _elem_, measured from the top left.
    # 
    #   <textarea id="example">           ## (scrolled to bottom right)
    #     123456789012345678901234567890
    #     2
    #     3
    #     4
    #   </textarea>
    #   
    #   Document['#example'].scroll   #=> {:x => 77, y: => 56}
    # 
    def scroll
      return self.window.scroll if self.is_body?
      `var elem = this.__native__`
      {:x => `elem.scrollLeft`, :y => `elem.scrollTop`}
    end
    
    # call-seq:
    #   elem.scroll_size -> {:x => integer, :y => integer}
    # 
    # Returns a hash containing the horizontal (_x_) and vertical (_y_)
    # dimensions in pixels of _elem_, including any portions that may have
    # scrolled out of view, but excluding the height and width of the scroll
    # bars.
    # 
    #   <textarea id="example">
    #     123456789012345678901234567890
    #     2
    #     3
    #     4
    #   </textarea>
    #   
    #   Document['#example'].scroll_size    #=> {:x => 235, y: => 84}
    # 
    def scroll_size
      return self.window.scroll_size if self.is_body?
      native_element = `this.__native__`
      {:x => `native_element.scrollWidth`, :y => `native_element.scrollHeight`}
    end
    
    # call-seq:
    #   elem.scroll_to(x,y) -> elem
    # 
    # Scrolls _elem_ to the position _x_ (horizontal) and _y_ (vertical)
    # pixels away from the top left corner of the area inside _elem_, then
    # returns _elem_. If a given dimension is larger than the maximum possible
    # scroll position, scrolls that dimension to the maximum scroll position.
    # 
    #   <textarea id="example">
    #     123456789012345678901234567890
    #     2
    #     3
    #     4
    #   </textarea>
    #   
    #   elem = Document['example']    #=> #<Element: TEXTAREA id="example">
    #   
    #   elem.scroll                     #=> {:x => 0, :y => 0}
    #   elem.scroll_to(10,10).scroll    #=> {:x => 10, :y => 10}
    #   elem.scroll_to(999,0).scroll    #=> {:x => 77, :y => 0}
    # 
    def scroll_to(x,y)
      if self.is_body?
        self.window.scroll_to(x, y)
      else
        native_element = `this.__native__`
        `native_element.scrollLeft = x`
        `native_element.scrollTop  = y`
      end
      return self
    end
    
    def scrolls # :nodoc:
      native_element = `this.__native__`
      x = 0
      y = 0
      `while (native_element && !c$Situated.c$Utilities.m$is_body_bool(native_element)){x+=native_element.scrollLeft;y+=native_element.scrollTop;elem=native_element.parentNode;}`
      {:x => x, :y => y}
    end
    
    # call-seq:
    #   elem.size -> {:x => integer, :y => integer}
    # 
    # Returns a hash containing the horizontal (_x_) and vertical (_y_)
    # dimensions in pixels of _elem_, including any padding or borders.
    # 
    #   <div id="example" style="height:200px;width:200px;padding:10px;border:1px solid #CC0404"></div>
    #   
    #   Document['#example'].size   #=> {:x => 222, :y => 222}
    # 
    def size
      return self.window.size if self.is_body?
      native_element = `this.__native__`
      {:x => `native_element.offsetWidth`, :y => `native_element.offsetHeight`}
    end
  end
  
  # Module <tt>Situated::Viewport</tt> provides the methods used by +Document+
  # and +Window+ when calling the methods in +PositionAndSize+.
  # 
  module Situated::Viewport
    include PositionAndSize
    
    # call-seq:
    #   viewport.position -> {:x => 0, :y => 0}
    # 
    # Returns a hash containing the horizontal (_x_) and vertical (_y_)
    # positions of the viewport in pixels, which are always (0,0).
    # 
    #   Document.position   #=> {:x => 0, :y => 0}
    # 
    def position
      {:x => 0, :y => 0}
    end
    
    # call-seq:
    #   viewport.scroll -> {:x => integer, :y => integer}
    # 
    # Returns a hash containing the horizontal (_x_) and vertical (_y_)
    # distance scrolled in pixels on the current page.
    # 
    #   Document.scroll   #=> {:x => 0, :y => 180}
    # 
    def scroll
      win = `#{self.window}.__native__`
      doc = `#{Situated::Utilities.native_compat_element(self)}.__native__`
      {:x => `win.pageXOffset||doc.scrollLeft`, :y => `win.pageYOffset||doc.scrollTop`}
    end
    
    # call-seq:
    #   viewport.scroll_size -> {:x => integer, :y => integer}
    # 
    # Returns a hash containing the horizontal (_x_) and vertical (_y_)
    # dimensions in pixels of the entire current page, including any portions
    # that may have scrolled out of view, but excluding the height and width
    # of the scroll bars.
    # 
    #   Document.scroll_size   #=> {:x => 1265, :y => 424}
    # 
    def scroll_size
      doc = `#{Situated::Utilities.native_compat_element(self)}.__native__`
      min = self.size
      {:x => `Math.max(doc.scrollWidth, #{min[:x]})`, :y => `Math.max(doc.scrollHeight,#{min[:y]})`}
    end
    
    # call-seq:
    #   viewport.size -> {:x => integer, :y => integer}
    # 
    # Returns a hash containing the horizontal (_x_) and vertical (_y_)
    # dimensions in pixels of the visible portion of the viewport.
    # 
    #   Document.size   #=> {:x => 1280, :y => 424}
    # 
    def size
      if presto? || webkit?
        win = `#{self.window}.__native__`
        return {:x => `win.innerWidth`, :y => `win.innerHeight`} if (presto? || webkit?)
      else
        doc = `#{Situated::Utilities.native_compat_element(self)}.__native__`
        return {:x => `doc.clientWidth`, :y => `doc.clientHeight`}
      end
    end
  end
  
  module Utilities # :nodoc:
    def self.is_body?(element)
      `(/^(?:body|html)$/i).test(element.tagName)`
    end
    
    def self.styleNumber(native_element, style)
      `parseInt(window.styleString(native_element, style)) || 0`
    end
    
    def self.border_box(element)
      `window.styleString(element, '-moz-box-sizing') == 'border-box'`
    end
    
    def self.top_border(element)
      `c$Situated.c$Utilities.m$styleNumber(element, 'border-top-width')`
    end
    
    def self.left_border(element)
      `c$Situated.c$Utilities.m$styleNumber(element, 'border-left-width')`
    end
    
    def self.native_compat_element(element)
      `var doc = #{element.document}.__native__`
      `$E((!doc.compatMode || doc.compatMode == 'CSS1Compat') ? doc.html : doc.body)`
    end
  end
end

class ::Element
  include Situated::Element
end

Document.extend(Situated::Viewport)
Window.extend(Situated::Viewport)