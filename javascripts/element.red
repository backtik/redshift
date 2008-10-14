module Element
  
  Attributes = {
  	:properties => {'html' => 'innerHTML', 'class' => 'className', 'for' => 'htmlFor', 'text' => (::Browser::Engine.trident?) ? 'innerText' : 'textContent'},
  	:booleans => ['compact', 'nowrap', 'ismap', 'declare', 'noshade', 'checked', 'disabled', 'readonly', 'multiple', 'selected', 'noresize', 'defer'],
  	:camels => ['value', 'accessKey', 'cellPadding', 'cellSpacing', 'colSpan', 'frameBorder', 'maxLength', 'readOnly', 'rowSpan', 'tabIndex', 'useMap']
  }
  
  Styles = {
  	:left => '@px', :top => '@px', :bottom => '@px', :right => '@px',
  	:width => '@px', :height => '@px', :maxWidth => '@px', :maxHeight => '@px', :minWidth => '@px', :minHeight => '@px',
  	:backgroundColor => 'rgb(@, @, @)', :backgroundPosition => '@px @px', :color => 'rgb(@, @, @)',
  	:fontSize => '@px', :letterSpacing => '@px', :lineHeight => '@px', :clip => 'rect(@px @px @px @px)',
  	:margin => '@px @px @px @px', :padding => '@px @px @px @px', :border => '@px @ rgb(@, @, @) @px @ rgb(@, @, @) @px @ rgb(@, @, @)',
  	:borderWidth => '@px @px @px @px', :borderStyle => '@ @ @ @', :borderColor => 'rgb(@, @, @) rgb(@, @, @) rgb(@, @, @) rgb(@, @, @)',
  	:zIndex => '@', :zoom => '@', :fontWeight => '@', :textIndent => '@px', :opacity => '@'
  }
  
  ShortStyles = {
    :margin => {}, :padding => {}, 
    :border => {}, :borderWidth => {}, 
    :borderStyle => {}, :borderColor => {}
  }
    
  class Extended
  	def initialize(tag)
      # konstructor = Element::Constructors.get(tag)
      #       return konstructor(properties)  if konstructor 
      # return Document.new_element(tag, props) if (`typeof tag == 'string'`) 
      # return Document[tag].set(properties)
      # return Document[tag]
      @native = tag
  	end
  	
  	def native
  	 @native
  	end
  	
  	def set(prop, value)
      case prop.class
      when ::Object
        nil
      when ::String
      property = ::Element::Attributes[:properties][prop]
      (property && property.respond_to?(:set)) ? property.set(self, value) : self.set_property(prop, value)
      end
      return self
  	end
  	
  	def get(prop)
	  	property = Element::Properties[prop]
      return (property && property.respond_to?(:get)) ? property.get(self,prop) : self.get_property(prop)
  	end
  	
  	def erase(prop)
  	 	property = Element::Properties[prop]
  	 	property ? property.erase(self, prop) : self.remove_property(prop)
  		return self
  	end
    
    def set_property(attribute, value)
      key = Element::Attributes[:properties][attribute]
      hasValue = defined?(value)
      if (key && Element::Attributes[:booleans].include?(attribute)) 
        value = (value || !hasValue) ? true : false
      elsif !hasValue
         return self.remove_property(attribute)
      end
      key ? `#{@native}[key] = value` : `#{@native}.setAttribute(attribute, value)`
  		return self
    end
    
    def get_property(attribute)
      key = Element::Attributes[:properties][attribute]
  		value = (key) ? `#{@native}[key]` : `#{@native}.getAttribute(attribute, 2)`
  		return Element::Attributes[:booleans].include?(attribute) ? !!value : (key) ? value : value || nil
    end
    
    def remove_property(attribute)
      #       key = Element::Attributes[:properties][attribute]
      #       is_bool = (key && Element::Attributes[:booleans][attribute])
      # (key) ? `#{self.native}[key]` = (is_bool) ? false : '' : self.remove_attribute(attribute);
      # return self
    end
    
    def set_properties(hash)
      hash.each {|attrbiute, value| self.set_property(attrbiute,value)}
      self
    end
    
    def get_properties(attribute_array)
      attributes = {}
      attribute_array.each {|attribute| attributes[attribute] = self.get_property(attribute)}
    end

    # def set_style(style, value)
    #   case style
    #   when 'opacity': return self.set('opacity', `parseFloat(value)`)
    #   when 'float': property = Browser::Engine.trident? ? 'styleFloat' : 'cssFloat'
    #   end
    # #   # property = property.camelCase();
    # #   if !value.is_a?(::String)
    # #     map = (Element::Styles[property] || '@').split(' ');
    # #     value = $splat(value).map(function(val, i){
    # #       if (!map[i]) return '';
    # #       return ($type(val) == 'number') ? map[i].replace('@', Math.round(val)) : val;
    # #     }).join(' ');
    # #   elsif (value == String(Number(value))){
    # #     value = Math.round(value);
    # #   end
    # #   `#{@native}.style[property] = value`
    #   return self
    # end
    
    def has_class?(name)
      !!(`$q(#{@native}.className)`).match(name)
    end
    
  	def add_class(name)
      `#{@native}.className = (#{@native}.className + ' ' + name)` unless self.has_class?(name)
  		return self
  	end
  end
  
  Properties = {
    'style' => Object.new,
    'tag'   => Object.new,
    'href'  => Object.new,
    'html'  => Object.new,
    'events'=> Object.new
  }
  
  def (Properties['style']).set(element, style)
    `#{element.native}.style.cssText = style`
  end
  
  def (Properties['style']).get(element)
		`#{element.native}.style.cssText`
	end

	def (Properties['style']).erase(element)
    `#{element.native}.style.cssText = ''`
	end
  
  def (Properties['tag']).get(element)
    `#{element.native}.tagName.toLowerCase()`
  end
  
  # TODO: REGEXP PORT REQUIRED
  # def (Properties['href']).get(element)
  #    # (`!#{element.native}.href`) ? nil : this.href.replace(new RegExp('^' + document.location.protocol + '\/\/' + document.location.host), '');
  # end
  
  def (Properties['html']).set(element, html)
    `#{element.native}.innerHTML = html`
  end

  
end