class Element
  
  def insert_before(element) # :nodoc:
    `if (#{self}.__native__.parentNode) #{self}.__native__.parentNode.insertBefore(#{element}.__native__, #{self}.__native__)`
    return true
  end
  
  def insert_after(element) # :nodoc
    `if (!element.parentNode) return`
    `next = #{self}.__native__.nextSibling`
    `(next) ? #{self}.__native__.parentNode.insertBefore(#{element}.__native__, next) : #{self}__native__.parentNode.appendChild(#{element}.__native__)`
    return true
  end
  
  def insert_bottom(element) # :nodoc
    `#{self}.__native__.appendChild(#{element}.__native__)`
    return true
  end
  alias :insert_inside :insert_bottom
  
  def insert_top(element) # :nodoc:
    `first = #{self}.__native__.firstChild`
    `(first) ? #{self}.__native__.insertBefore(#{element}.__native__, first) : #{self}.__native__.appendChild(#{element}.__native__)`
    return true
  end
  
  def insert(element, where = :bottom)
    self.send("insert#{where.to_s.capitalize}", element)
    self
  end
  
  # call-seq:
  #   elem.is_body? -> true or false
  # 
  # Returns +true+ if the element is the body element, +false+ otherwise.
  # 
  #   Document['#my_id'].is_body?    #=> false
  #   Document.body.is_body?         #=> true
  #
  def is_body?
    `return (/^(?:body|html)$/i).test(#{element}.__native__.tagName)`
  end
  
  # def initialize(tag)
  #   # konstructor = ElementStuff::Constructors.get(tag)
  #   #       return konstructor(properties)  if konstructor 
  #   # return Document.new_element(tag, props) if (`typeof tag == 'string'`) 
  #   # return Document[tag].set(properties)
  #   # return Document[tag]
  #   @native = tag
  # end
  # 
  # def native
  #   `this.__native__`
  # end
  # 
  # def set(prop, value)
  #   case prop.class
  #   when Object
  #     nil
  #   when String
  #   property = ElementStuff::Attributes[:properties][prop]
  #   (property && property.respond_to?(:set)) ? property.set(self, value) : self.set_property(prop, value)
  #   end
  #   return self
  # end
  # 
  # def get(prop)
  #   property = ElementStuff::Properties[prop]
  #   return (property && property.respond_to?(:get)) ? property.get(self,prop) : self.get_property(prop)
  # end
  # 
  # def erase(prop)
  #   property = ElementStuff::Properties[prop]
  #   property ? property.erase(self, prop) : self.remove_property(prop)
  #   return self
  # end
  # 
  # def set_property(attribute, value)
  #   key = ElementStuff::Attributes[:properties][attribute]
  #   hasValue = defined?(value)
  #   if (key && ElementStuff::Attributes[:booleans].include?(attribute)) 
  #     value = (value || !hasValue) ? true : false
  #   elsif !hasValue
  #      return self.remove_property(attribute)
  #   end
  #   key ? `#{@native}[key] = value` : `#{@native}.setAttribute(attribute, value)`
  #   return self
  # end
  # 
  # def get_property(attribute)
  #   key = ElementStuff::Attributes[:properties][attribute]
  #   value = (key) ? `#{@native}[key]` : `#{@native}.getAttribute(attribute, 2)`
  #   return ElementStuff::Attributes[:booleans].include?(attribute) ? !!value : (key) ? value : value || nil
  # end
  # 
  # def remove_property(attribute)
  #   #       key = ElementStuff::Attributes[:properties][attribute]
  #   #       is_bool = (key && ElementStuff::Attributes[:booleans][attribute])
  #   # (key) ? `#{self.native}[key]` = (is_bool) ? false : '' : self.remove_attribute(attribute);
  #   # return self
  # end
  # 
  # def set_properties(hash)
  #   hash.each {|attrbiute, value| self.set_property(attrbiute,value)}
  #   self
  # end
  # 
  # def get_properties(attribute_array)
  #   attributes = {}
  #   attribute_array.each {|attribute| attributes[attribute] = self.get_property(attribute)}
  # end
  # 
  # # def set_style(style, value)
  # #   case style
  # #   when 'opacity': return self.set('opacity', `parseFloat(value)`)
  # #   when 'float': property = Browser::Engine.trident? ? 'styleFloat' : 'cssFloat'
  # #   end
  # # #   # property = property.camelCase();
  # # #   if !value.is_a?(::String)
  # # #     map = (Element::Styles[property] || '@').split(' ');
  # # #     value = $splat(value).map(function(val, i){
  # # #       if (!map[i]) return '';
  # # #       return ($type(val) == 'number') ? map[i].replace('@', Math.round(val)) : val;
  # # #     }).join(' ');
  # # #   elsif (value == String(Number(value))){
  # # #     value = Math.round(value);
  # # #   end
  # # #   `#{@native}.style[property] = value`
  # #   return self
  # # end
  # 
  # def has_class?(name)
  #   !!(`$q(#{@native}.className)`).match(name)
  # end
  # 
  # def add_class(name)
  #   `#{@native}.className = (#{@native}.className + ' ' + name)` unless self.has_class?(name)
  #   return self
  # end
  # 
  # module ElementStuff
  #   Attributes = {
  #     :properties => {'html' => 'innerHTML', 'class' => 'className', 'for' => 'htmlFor', 'text' => (::Browser::Engine.trident?) ? 'innerText' : 'textContent'},
  #     :booleans => ['compact', 'nowrap', 'ismap', 'declare', 'noshade', 'checked', 'disabled', 'readonly', 'multiple', 'selected', 'noresize', 'defer'],
  #     :camels => ['value', 'accessKey', 'cellPadding', 'cellSpacing', 'colSpan', 'frameBorder', 'maxLength', 'readOnly', 'rowSpan', 'tabIndex', 'useMap']
  #   }
  #   
  #   Styles = {
  #     :left => '@px', :top => '@px', :bottom => '@px', :right => '@px',
  #     :width => '@px', :height => '@px', :maxWidth => '@px', :maxHeight => '@px', :minWidth => '@px', :minHeight => '@px',
  #     :backgroundColor => 'rgb(@, @, @)', :backgroundPosition => '@px @px', :color => 'rgb(@, @, @)',
  #     :fontSize => '@px', :letterSpacing => '@px', :lineHeight => '@px', :clip => 'rect(@px @px @px @px)',
  #     :margin => '@px @px @px @px', :padding => '@px @px @px @px', :border => '@px @ rgb(@, @, @) @px @ rgb(@, @, @) @px @ rgb(@, @, @)',
  #     :borderWidth => '@px @px @px @px', :borderStyle => '@ @ @ @', :borderColor => 'rgb(@, @, @) rgb(@, @, @) rgb(@, @, @) rgb(@, @, @)',
  #     :zIndex => '@', :zoom => '@', :fontWeight => '@', :textIndent => '@px', :opacity => '@'
  #   }
  #   
  #   ShortStyles = {
  #     :margin => {}, :padding => {}, 
  #     :border => {}, :borderWidth => {}, 
  #     :borderStyle => {}, :borderColor => {}
  #   }
  #   
  #   Properties = {
  #     'style' => Object.new,
  #     'tag'   => Object.new,
  #     'href'  => Object.new,
  #     'html'  => Object.new,
  #     'events'=> Object.new
  #   }
  #   
  #   def (Properties['style']).set(element, style)
  #     `#{element.native}.style.cssText = style`
  #   end
  #   
  #   def (Properties['style']).get(element)
  #     `#{element.native}.style.cssText`
  #   end
  #   
  #   def (Properties['style']).erase(element)
  #     `#{element.native}.style.cssText = ''`
  #   end
  #   
  #   def (Properties['tag']).get(element)
  #     `#{element.native}.tagName.toLowerCase()`
  #   end
  #   
  #   # TODO: REGEXP PORT REQUIRED
  #   # def (Properties['href']).get(element)
  #   #   r = Regexp.new('^' + `$q(document.location.protocol)` + '\/\/' + `$q(document.location.host)`)
  #   #   (`#{element.native}.href`) ? nil : `#{element.native}.href`.replace(r, '')
  #   # end
  #   
  #   def (Properties['html']).set(element, html)
  #     `#{element.native}.innerHTML = html`
  #   end
  # end
end