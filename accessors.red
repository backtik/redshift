require 'javascripts/element.red'

class Element
  `c$Element.__keyed_attributes__={class:'className',for:'htmlFor'}`
  `c$Element.__boolean_attributes__={checked:'checked',declare:'declare',defer:'defer',disabled:'disabled',ismap:'ismap',multiple:'multiple',noresize:'noresize',noshade:'noshade',readonly:'readonly',selected:'selected'}`
  
  # call-seq:
  #   elem.add_class(sym) -> elem
  # 
  # Returns _elem_ with class name _sym_ added.
  # 
  #   
  # 
  def add_class(sym)
    `if(!this.m$has_class_bool(sym)){var el=this.__native__,c=el.className,s=sym.__value__;el.className=(c.length>0)?c+' '+s:s;}`
    return self
  end
  
  # call-seq:
  #   elem.add_classes(sym, ...) -> elem
  # 
  # Calls <tt>elem.add_class(sym)</tt> once for each argument.
  # 
  #   
  # 
  def add_classes(*args)
    args.each {|x| self.add_class(x) }
    return self
  end
  
  # call-seq:
  #   elem.class -> string
  # 
  # Returns a string representation of _elem_'s class names, separated by " ".
  # 
  #   
  # 
  def class
    `$q(this.__native__.className)`
  end
  
  # call-seq:
  #   elem.class = str -> str
  # 
  # Sets _elem_'s HTML class property to _str_, which consists of one or many
  # class names separated by " ".
  # 
  #   
  # 
  def class=(str)
    `this.__native__.className=str.__value__`
    return str
  end
  
  # call-seq:
  #   elem.classes -> object
  # 
  # Returns an Element::Classes accessor object, which represents the classes
  # assigned to _elem_, and allows for operations such as
  # <tt>elem.classes << :klass</tt>, <tt>elem.classes.include? :klass</tt>,
  # and <tt>elem.classes.toggle(:klass)</tt>.
  # 
  #   
  # 
  def classes
    @class_list ||= Element::Classes.new(self)
  end
  
  # call-seq:
  #   elem.classes = [sym, ...] -> array
  # 
  # Sets _elem_'s HTML class property to a string equivalent to the
  # concatenation of each of the classes in _array_ joined by " ", then
  # returns _array_.
  # 
  #   
  # 
  def classes=(ary)
    `for(var result=[],i=0,l=ary.length;i<l;++i){result.push(ary[i].__value__);}`
    `this.__native__.className=result.join(' ')`
    return ary
  end
  
  # call-seq:
  #   elem.clear_styles -> elem
  # 
  # Removes the CSS styles that have been applied to _elem_.
  # 
  #   
  # 
  def clear_styles
    `this.__native__.style.cssText=''`
    return self
  end
  
  # call-seq:
  #   elem.get_property(sym) -> object or nil
  # 
  # Returns the value of _elem_'s property _sym_, or +nil+ if no value is set.
  # 
  #   
  # 
  def get_property(attribute)
    `var el=this.__native__,attr=attribute.__value__,key=c$Element.__keyed_attributes__[attr],bool=c$Element.__boolean_attributes__[attr]`
    `var value=key||bool?el[key||bool]:el.getAttribute(attr,2)`
    return `bool ? !!value : (value==null) ? nil : $q(value)`
  end
  
  # call-seq:
  #   elem.get_style(sym) -> object or nil
  # 
  # Returns the value of the CSS style rule _sym_ applied to _elem_, or +nil+
  # if no value is set.
  # 
  #   
  # 
  def get_style(attribute)
    `var el=this.__native__,attr=attribute.__value__.replace(/[_-]\\D/g, function(match){return match.charAt(1).toUpperCase();}),result=el.style[attr]`
    `result===undefined?nil:$q(result)`
  end
  
  # call-seq:
  #   elem.has_class?(sym) -> true or false
  # 
  # Returns +true+ if _elem_ has class _sym_, +false+ otherwise.
  # 
  #   <div id='div_a' class='container drop_target'></div>
  #   
  #   elem = Document['#div_a']       #=> #<Element: DIV id="div_element" class="container drop_target">
  #   elem.has_class?('container')    #=> true
  #   elem.has_class?(:draggable)     #=> false
  # 
  def has_class?(sym)
    `var str=' '+this.__native__.className+' ',match=' '+sym.__value__+' '`
    `str.indexOf(match) > -1`
  end
  
  # call-seq:
  #   elem.html -> string
  # 
  # Returns a string representation of the HTML inside _elem_.
  # 
  #   
  # 
  def html
    `$q(this.__native__.innerHTML)`
  end
  
  # call-seq:
  #   elem.html = str -> str
  # 
  # Sets the HTML inside _elem_ to _str_.
  # 
  #   
  # 
  def html=(str)
    `this.__native__.innerHTML=str.__value__`
    return str
  end
  
  # call-seq:
  #   elem.properties -> object
  # 
  # Returns an Element::Properties accessor object, which represents the
  # HTML properties assigned to _elem_, and allows for operations such as
  # <tt>elem.properties[:title] = 'figure_1'</tt> and
  # <tt>elem.properties.set? :name</tt>.
  # 
  #   
  # 
  def properties
    @properties ||= Element::Properties.new(self)
  end
  
  # call-seq:
  #   elem.remove_class(sym) -> elem
  # 
  # Removes _sym_ from _elem_'s HTML class property if it was included, then
  # returns _elem_.
  # 
  #   
  # 
  def remove_class(sym)
    `var el=this.__native__,klass=sym.__value__`
    `el.className=el.className.replace(new(RegExp)('(^|\\\\s)'+klass+'(?:\\\\s|$)'),'$1')`
    return self
  end
  
  # call-seq:
  #   elem.remove_classes(sym, ...) -> elem
  # 
  # Calls <tt>elem.remove_class(sym)</tt> once for each argument.
  # 
  #   
  # 
  def remove_classes(*args)
    args.each {|x| self.remove_class(x) }
    return self
  end
  
  # call-seq:
  #   elem.remove_property(sym) -> elem
  # 
  # Unsets _elem_'s HTML property _sym_ if it was set, then returns _elem_.
  # 
  #   
  # 
  def remove_property(attribute)
    `var el=this.__native__,attr=attribute.__value__,bool=c$Element.__boolean_attributes__[attr],key=c$Element.__boolean_attributes__[attr]||bool`
    `key ? el[key]=bool?false:'' : el.removeAttribute(attr)`
    return self
  end
  
  # call-seq:
  #   elem.remove_properties(sym, ...) -> elem
  # 
  # Calls <tt>elem.remove_property(sym)</tt> once for each argument.
  # 
  #   
  # 
  def remove_properties(*args)
    args.each {|x| self.remove_property(x) }
    return self
  end
  
  # call-seq:
  #   elem.remove_style(sym) -> elem
  # 
  # Unsets _elem_'s CSS style _sym_ if it was set, then returns _elem_.
  # 
  #   
  # 
  def remove_style(attribute)
    `var attr=attribute.__value__.replace(/[_-]\\D/g, function(match){return match.charAt(1).toUpperCase();})`
    `this.__native__.style[attr]=null`
    return self
  end
  
  # call-seq:
  #   elem.remove_styles(sym, ...) -> elem
  # 
  # Calls <tt>elem.remove_style(sym)</tt> once for each argument.
  # 
  #   
  # 
  def remove_styles(*args)
    args.each {|x| self.remove_style(x) }
    return self
  end
  
  # call-seq:
  #   elem.set_property(sym, value) -> elem
  # 
  # Sets _elem_'s HTML property _sym_ to _value_, then returns _elem_.
  # 
  #   
  # 
  def set_property(attribute, value)
    `var el=this.__native__,attr=attribute.__value__,bool=c$Element.__boolean_attributes__[attr],key=c$Element.__boolean_attributes__[attr]||bool`
    `key ? el[key]=bool?$T(value):value : el.setAttribute(attr,''+value)`
    return self
  end
  
  # call-seq:
  #   elem.set_properties({key => value, ...}) -> elem
  # 
  # Calls <tt>elem.set_property(key,value)</tt> once for each key-value pair.
  # 
  #   
  # 
  def set_properties(hash)
    hash.each {|k,v| self.set_property(k,v) }
    return self
  end
  
  # call-seq:
  #   elem.set_style(sym, value) -> elem
  # 
  # Sets _elem_'s CSS style _sym_ to _value_, then returns _elem_.
  # 
  #   
  # 
  def set_style(attribute, value)
    `var attr=attribute.__value__.replace(/[_-]\\D/g, function(match){return match.charAt(1).toUpperCase();}),val=value.__value__||value`
    `if(attr==='float'){val=#{trident?}?'styleFloat':'cssFloat'}`
    `if(attr==='opacity'){m$raise("nobody wrote the opacity setter yet!");}`
    `if(val===String(Number(val))){val=Math.round(val)}`
    `this.__native__.style[attr]=val`
    return self
  end
  
  # call-seq:
  #   elem.set_styles({key => value, ...}) -> elem
  # 
  # Calls <tt>elem.set_style(key,value)</tt> once for each key-value pair.
  # 
  #   
  # 
  def set_styles(hash)
    hash.each {|k,v| self.set_style(k,v) }
    return self
  end
  
  # call-seq:
  #   elem.style -> string
  # 
  # Returns the value of _elem_'s HTML style property.
  # 
  #   
  # 
  def style
    `$q(this.__native__.style.cssText)`
  end
  
  # call-seq:
  #   elem.style = str -> str
  # 
  # Sets the value of _elem_'s HTML style property to _str_.
  # 
  #   
  # 
  def style=(str)
    `this.__native__.style.cssText=str.__value__`
    return str
  end
  
  # call-seq:
  #   elem.styles -> object
  # 
  # Returns an Element::Styles accessor object, which represents the CSS
  # styles applied to _elem_, and allows for operations such as
  # <tt>elem.styles[:color] = '#C80404'</tt> and
  # <tt>elem.styles.set? :font_weight</tt>.
  # 
  #   
  # 
  def styles
    @styles ||= Element::Styles.new(self)
  end
  
  # call-seq:
  #   elem.text -> string
  # 
  # Returns the text inside _elem_ as a string.
  # 
  #   
  # 
  def text
    `$q(#{trident?} ? this.__native__.innerText : this.__native__.textContent)`
  end
  
  # call-seq:
  #   elem.text = str -> str
  # 
  # Sets the text inside _elem_ to the value _str_.
  # 
  #   
  # 
  def text=(str)
    trident? ? `this.__native__.innerText=str.__value__` : `this.__native__.textContent=str.__value__`
    return str
  end
  
  # call-seq:
  #   elem.toggle_class(sym) -> elem
  # 
  # Returns _elem_ with the HTML class _sym_ added to its HTML classes if
  # they did not include _sym_, or with _sym_ removed from its HTML classes if
  # they did include _sym_.
  # 
  #   
  # 
  def toggle_class(sym)
    self.has_class?(sym) ? self.remove_class(sym) : self.add_class(sym);
    return self
  end
  
  # 
  # 
  class Classes
    def initialize(element) # :nodoc:
      @element = element
    end
    
    # call-seq:
    #   classes << sym -> classes
    # 
    # Adds _sym_ to the HTML classes of the element represented by _classes_,
    # then returns _classes_. See also <tt>Element#add_class</tt>.
    # 
    #   
    # 
    def <<(sym)
      `c$Element.prototype.m$add_class.call(#{@element},sym)`
      return self
    end
    
    # call-seq:
    #   classes.include?(sym) -> true or false
    # 
    # Returns +true+ if the element represented by _classes_ has the HTML
    # class _sym_, +false+ otherwise. See also <tt>Element#has_class?</tt>.
    # 
    #   
    # 
    def include?(sym)
      `c$Element.prototype.m$has_class_bool.call(#{@element},sym)`
    end
    
    # call-seq:
    #   classes.toggle(sym) -> element
    # 
    # If the element represented by _classes_ has the HTML class _sym_,
    # removes _sym_; otherwise, adds _sym_ to the element's classes. See also
    # <tt>Element#toggle_class</tt>.
    # 
    #   
    # 
    def toggle(sym)
      `c$Element.prototype.m$toggle_class.call(#{@element},sym)`
      return @element
    end
  end
  
  # 
  # 
  class Properties
    def initialize(element) # :nodoc:
      @element = element
    end
    
    # call-seq:
    #   properties[sym] -> object or nil
    # 
    # Returns the value of the HTML property _sym_ for the element represented
    # by _properties_, or +nil+ if the property is not set. See also
    # <tt>Element#get_property</tt>.
    # 
    #   
    # 
    def [](attribute)
      `c$Element.prototype.m$get_property.call(#{@element},attribute)`
    end
    
    # call-seq:
    #   properties[sym] = value -> value
    # 
    # Sets the value of the HTML property _sym_ to _value_ for the element
    # represented by _properties_. See also <tt>Element#set_property</tt>.
    # 
    #   
    # 
    def []=(attribute,value)
      `c$Element.prototype.m$set_property.call(#{@element},attribute,value)`
    end
    
    # call-seq:
    #   properties.delete(sym) -> object or nil
    # 
    # If the element represented by _properties_ has the HTML property _sym_,
    # unsets the property and returns its value, otherwise returns +nil+. See
    # also <tt>Element#remove_property</tt>.
    # 
    #   
    # 
    def delete(attribute)
      `c$Element.prototype.m$remove_property.call(#{@element},attribute)`
    end
    
    # call-seq:
    #   properties.set?(sym) -> true or false
    # 
    # Returns +true+ if the HTML property _sym_ is set for the element
    # represented by _properties_, +false+ otherwise. 
    # 
    #   
    # 
    def set?(attribute)
      `$T(c$Element.prototype.m$get_property.call(#{@element},attribute))`
    end
    
    # call-seq:
    #   properties.update({key => value, ...}) -> properties
    # 
    # Sets the value of the HTML property _key_ of the element represented by
    # _properties_ to _value_ for each key-value pair, then returns
    # _properties_. See also <tt>Element#set_properties</tt>.
    # 
    #   
    # 
    def update(hash)
      `c$Element.prototype.m$set_properties.call(#{@element},hash)`
      return self
    end
  end
  
  # 
  # 
  class Styles
    def initialize(element) # :nodoc:
      @element = element
    end
    
    # call-seq:
    #   styles[sym] -> object
    # 
    # Returns the value of the CSS style _sym_ for the element represented by
    # _styles_, or +nil+ if no such style is applied. See also
    # <tt>Element#get_style</tt>.
    # 
    #   
    # 
    def [](attribute)
      `c$Element.prototype.m$get_style.call(#{@element},attribute)`
    end
    
    # call-seq:
    #   styles[sym] = value -> value
    # 
    # Sets the value of the CSS style _sym_ to _value_ for the element
    # represented by _styles_. See also <tt>Element#set_style</tt>.
    # 
    #   
    # 
    def []=(attribute, value)
      `c$Element.prototype.m$set_style.call(#{@element},attribute,value)`
    end
    
    # call-seq:
    #   styles.clear -> styles
    # 
    # Removes the CSS styles that have been applied to the element represented
    # by _styles_. See also <tt>Element#clear_styles</tt>.
    # 
    #   
    # 
    def clear
      `c$Element.prototype.m$clear_styles.call(#{@element})`
    end
    
    # call-seq:
    #   styles.delete(sym) -> object or nil
    # 
    # If the element represented by _styles_ has the CSS style _sym_ applied,
    # removes the style and returns its value, otherwise returns +nil+. See
    # also <tt>Element#remove_style</tt>.
    # 
    #   
    # 
    def delete(attribute)
      `c$Element.prototype.m$remove_style.call(#{@element},attribute)`
    end
    
    # call-seq:
    #   styles.set?(sym) -> true or false
    # 
    # Returns +true+ if the element represented by _styles_ has the CSS style
    # _sym_ applied, +false+ otherwise.
    # 
    #   
    # 
    def set?(attribute)
      `$T(c$Element.prototype.m$get_style.call(#{@element},attribute))`
    end
    
    # call-seq:
    #   styles.update({key => value, ...}) -> styles
    # 
    # Sets the value of the CSS style _key_ of the element represented by
    # _styles_ to _value_ for each key-value pair, then returns _styles_.
    # See also <tt>Element#set_styles</tt>.     
    # 
    #   
    # 
    def update(hash)
      `c$Element.prototype.m$set_styles.call(#{@element},hash)`
      return self
    end
  end
end
