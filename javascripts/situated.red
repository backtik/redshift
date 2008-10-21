# Classes mixing in <tt>Situated</tt> and its submodules gain the ability
# to provide locational and dimensional data about their visual DOM 
# representation within the browser.
#
module Situated
  module PositionAndSize
    
    # call-seq:
    #   situated.height -> integer
    # returns the height of the _situated_ in pixels as an integer.
    # height is the amount of vertical space the content requires
    # plus top padding, bottom padding, top border, and bottom border, if any
    #
    #
    # For example,
    # situated = Document['#situated']
    # where _situated_ is an element whose content is 200px tall 
    # with a top padding of 20px, bottom padding of 10px
    # and a top border of 1px
    # 
    # situated.height #=> 231 (200 + 20 + 10 + 1)
    #
    def height
      self.size[:y]
    end
    
    # call-seq:
    #   situated.width -> integer
    # returns the width of the _situated_ in pixels as an integer 
    # width is the amount of horizontal space the content requires
    # plus left padding, right padding, left border, and right border, if any
    #
    # For example,
    # situated = Document['#situated']
    # where _situated_ is an element whose content is 200px wide 
    # with a left padding of 20px, right padding of 10px
    # and a left border of 1px
    # 
    # situated.width #=> 231 (200 + 20 + 10 + 1)
    #
    def width
      self.size[:x]
    end
    
    def scroll_top
      self.scroll[:y]
    end
    
    def scroll_left
      self.scroll[:x]
    end
    
    def scroll_height
      self.scroll_size[:y]
    end
    
    def scroll_width
      self.scroll_size[:x]
    end
    
    def top
      self.position[:x]
    end
    
    def left
      self.position[:y]
    end
  end
  
  module Element
    include PositionAndSize
    
    def size
      return self.window.size if self.is_body?
  		return {:x => `#{self}.__native__.offsetWidth`, :y => `#{self}.__native__.offsetHeight`}
    end
    
    # call-seq:
    #   situated.scroll -> hash
    # returns a hash containing keys <tt>:x<tt> and <tt>:y<tt> representing the 
    # the distance that a _situated_ has been scrolled
    # originating at the top left corner of the _situated_
    # 
    # For example if a _situated_ has been scrolled 10px left and 5px down
    # situated.scroll #=> {:x => 10, :y => 5}
    def scroll
      return self.window.scroll if self.is_body? 
  		return {:x => `#{self}.__native__.scrollLeft`, :y => `#{self}.__native__.scrollTop`}
    end
    
    def scrolls
      element = self
      position = {:x => 0, :y => 0}
  		while element && !element.is_body? do
  			position[:x] += `#{element}.__native__.scrollLeft`
  			position[:y] += `#{element}.__native__.scrollTop`
  			element = `$E(#{element}.__native__.parentNode)`
  		end
  		return position
    end
    
    # call-seq:
    #   situated.scroll_size -> hash
    # returns a hash containing keys <tt>:x<tt> and <tt>:y<tt> representing the 
    # the size that a _situated_ included potential scrollable area.
    #
    # For example if a _situated_ has been a visible width of 100px and visible height of 50px
    # and 100 additional pixels of horizontal unseen content that can be scrolled to uncover
    #  
    # situated.scroll_size #=> {:x => 200, :y => 50}
    #
    def scroll_size
      return self.window.scroll_size if self.is_body?
  		return {:x => `#{self}.__native__.scrollWidth`, :y => `#{self}.__native__.scrollHeight`}
    end
    
    # call-seq:
    #   situated.scroll_to(x,y) -> situated
    # 
    # Scrolls the _situated_ to the position referenced by the coordinates <tt>x</tt> and <tt>y</tt>
    # which are pixel dimensions measured from the top left corner of hte _situated_
    #
    # Will scroll to the limit of one dimension if a cooridnate for that dimension
    # is larger than the size element
    #
    # No scrolling in a direction will occur if scrolling in that direction would have no effect.
    #
    # Examples:
    #
    # Given a _situated_ that is 200px wide and 500px long and has
    # only 150px of horizontal dimension visible at any time and 
    # only 200px of vertical dimension visible at any time
    #
    # situated.scroll_to(10,10)
    # will scroll the visible area 10 pixels from the left and 10pixels from the top
    # 
    # scroll.scroll_to(200,0) will scroll the _situated_ to the maximum left scrolling possible
    # and return the _situated_ to the original height position.
    #
    def scroll_to(x,y)
      if self.is_body?
        self.window.scroll_to(x, y)
      else
        self.scroll_left = x
        self.scoll_top   = y
      end
  		return self
    end
    
    # call-seq:
    #   situated.offset_parent -> element
    #
    # returns the parent element that provides the visual offset from
    # the top left corner of the viewport
    # 
    # This is typically the closest statically position element or <tt>body</tt>
    def offset_parent
      element = self
      return nil if element.is_body?
      
      # All engines except trident have a native offsetParent property
      return `$E(#{element}.__native__.offsetParent)` unless trident?
      
      # For trident we walk the DOM until we have a static positioned element or reach the body
  		while ((element = `$E(#{element}.__native__.parentNode)`) && !element.is_body?) do 
  		  return element unless element.styles[:position] == 'static'
  		end
  		
  		return nil
    end
    
    def offsets
      element = self
      position = {:x => 0, :y => 0}
      return position if self.is_body?

  		while (element && !element.is_body?) do
  			position[:x] += `#{element}.__native__.offsetLeft`
  			position[:y] += `#{element}.__native__.offsetTop`

  			if gecko?
  				if !element.styles['border-box']
  					position[:x] += element.styles['border-left-width']
  					position[:y] += element.styles['border-top-width']
  				end
  				
  				parent = `$E(#{element}.__native__.parentNode)`
  				
  				if parent && parent.styles[:overflow] != 'visible'
  					position[:x] += parent.styles['border-left-width']
  					position[:y] += parent.styles['border-top-width']
  			  elsif element != self && (trident? || webkit?)
  				  position[:x] += element.styles['border-left-width']
  				  position[:y] += element.styles['border-top-width']
				  end
  			end

  			element = element.offset_parent #`$E(#{element}.__native__.offsetParent)`
  			
  			if trident?
  				element = element.offset_parent while (element && !`#{element}.__native__.currentStyle.hasLayout`) 
  			end
  		end
  		
  		if (gecko? && !self.styles['border-box'])
  			position[:x] -= self.styles['border-left-width']
  			position[:y] -= self.styles['border-top-width']
  		end
  		
  		return position
    end
    
    def position(hash)
      return self.styles << self.calculate_position(hash)
    end
    
    def calculate_position(hash)
      {:left => hash[:x] - self.styles['margin-left'], :top => hash[:y] - self.styles['margin-top']}
    end
    
    def coordinates
      # if (isBody(this)) return this.getWindow().getCoordinates();
      # var position = this.getPosition(element), size = this.getSize();
      # var obj = {left: position.x, top: position.y, width: size.x, height: size.y};
      # obj.right = obj.left + obj.width;
      # obj.bottom = obj.top + obj.height;
      # return obj;
    end
  end
  
  
  module Viewport
    include PositionAndSize
    
    def size
      win = self.window
  	  return {:x => `#{win}.__native__.innerWidth`, :y => `#{win}.__native__.innerHeight`} if (presto? || webkit?)
  		doc = getCompatElement(self)
  		return {:x => `#{doc}.__native__.clientWidth`, :y => `#{doc}.__native__.clientHeight`}
    end
    
    def scroll
      win = self.window
  		doc = getCompatElement(self)
  		return {:x => `#{win}.__native__.pageXOffset` || `#{doc}.__native__.scrollLeft`, :y => `#{win}.__native__pageYOffset` || `#{doc}.__native__.scrollTop`}
    end
    
    def scroll_size
      doc = getCompatElement(self);
  		min = self.size
  		return {:x => `Math.max(#{doc}.__native__.scrollWidth, #{min[:x]})`, :y => `Math.max(#{doc}.__native__.scrollHeight,#{ min[:y]})`}
    end
    
    # call-seq:
    #   viewport.position -> hash
    # returns the position of the viewport, which is always {:x => 0, :y => 0} 
    #
    def position
      return {:x => 0, :y => 0}
    end
    
    # call-seq:
    #   viewport.position -> hash
    # returns the coordinates of the viewport in pixesl as integers 
    # within a hash with the keys
    # :top
    # :left
    # :bottom
    # :right
    # :height
    # :width
    #
    # For example, a _viewport_ that is 500px wide and 800px tall will return
    # viewport.coordinates
    # {:top     => 0,
    #  :left    => 0,
    #  :bottom  => 800,
    #  :right   => 500,
    #  :height  => 800,
    #  :width   => 500 }
    #
    def coordinates
      size = self.size
  		return {:top => 0, :left => 0, :bottom => size[:y], :right => size[:x], :height => size[:y], :width => size[:x]}
    end
  end
end