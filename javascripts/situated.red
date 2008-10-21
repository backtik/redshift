# Classes mixing in <tt>Situated</tt> and its submodules gain the ability
# to provide locational and dimensional data about their visual DOM 
# representation within the browser.
#
module Situated
  module Base
    
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
    def size
      return self.window.size if self.is_body?
  		return {:x => self.native.offset_width, :y => self.native.offset_height}
    end
    
    def scroll
      return self.window.scroll if self.is_body? 
  		return {:x => self.scroll_left, :y => this.scroll_top}
    end
    
    def scrolls
      element = self
      position = {:x => 0, :y => 0}
  		while element && !element.is_body? do
  			position[:x] += element.scroll_left
  			position[:y] += element.scroll_top
  			element = element.native.parent_node
  		end
  		return position
    end
    
    def scroll_size
      return self.window.scroll_size if self.is_body?
  		return {:x => self.scroll_width, :y => self.scroll_height}
    end
    
    def scroll_to(x,y)
      if self.is_body?
        self.window.scroll_to(x, y)
      else
        self.scroll_left = x
        self.scoll_top   = y
      end
  		return self
    end
    
    def offset_parent
      element = self
      return nil if element.is_body?
      
      # TODO:
      # Element.wrap(element.native.offset_parent)
      return element.native.offset_parent unless trident?

  		while ((element = element.native.parent_node) && !element.is_body?) do 
  		  return element unless element.styles[:position] == 'static'
  		end
  		
  		return nil
    end
    
    def offsets
      element = self
      position = {:x => 0, :y => 0}
      return position if self.is_body?

  		while (element && !element.is_body?) do
  			position[:x] += element.offset_left
  			position[:y] += element.offset_top

  			if gecko?
  				if !element.styles['border-box']
  					position[:x] += element.styles['border-left-width']
  					position[:y] += element.styles['border-top-width']
  				end
  				parent = element.native.parent_node
  				
  				if parent && parent.styles[:overflow] != 'visible'
  					position[:x] += parent.styles['border-left-width']
  					position[:y] += parent.styles['border-top-width']
  			  elsif element != self && (trident? || webkit?)
  				  position[:x] += element.styles['border-left-width']
  				  position[:y] += element.styles['border-top-width']
				  end
  			end

  			element = element.native.offset_parent
  			
  			if trident?
  				element = element.native.offset_parent while (element && !element.native.currentStyle.hasLayout) 
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
    def size
      win = self.window
  	  return {:x => win.native.innerWidth, :y => win.native.innerHeight} if (presto? || webkit?)
  		doc = getCompatElement(self)
  		return {:x => doc.native.clientWidth, :y => doc.native.clientHeight}
    end
    
    def scroll
      win = self.window
  		doc = getCompatElement(self)
  		return {:x => win.pageXOffset || doc.scrollLeft, :y => win.pageYOffset || doc.scrollTop}
    end
    
    def scroll_size
      doc = getCompatElement(self);
  		min = self.size
  		return {:x => Math.max(doc.scrollWidth, min.x), :y => Math.max(doc.scrollHeight, min.y)}
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