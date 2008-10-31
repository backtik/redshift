class Element
  `c$Element.__keyed_attributes__={class:'className',for:'htmlFor'}`
  `c$Element.__boolean_attributes__={checked:'checked',declare:'declare',defer:'defer',disabled:'disabled',ismap:'ismap',multiple:'multiple',noresize:'noresize',noshade:'noshade',readonly:'readonly',selected:'selected'}`
  
  # call-seq:
  #   elem.add_class(sym) -> elem
  # 
  def add_class(sym)
    `if(!this.m$has_class_bool(sym)){var el=this.__native__,c=el.className,s=sym.__value__;el.className=(c.length>0)?c+' '+s:s;}`
    return self
  end
  
  # call-seq:
  #   elem.add_classes(sym, ...) -> elem
  # 
  def add_classes(*args)
    args.each {|x| self.add_class(x) }
    return self
  end
  
  # call-seq:
  #   elem.class -> string
  # 
  def class
    `$q(this.__native__.className)`
  end
  
  # call-seq:
  #   elem.class = str -> str
  # 
  def class=(str)
    `this.__native__.className=str.__value__`
    return str
  end
  
  # call-seq:
  #   elem.classes -> object
  # 
  def classes
    @class_list ||= Element::Classes.new(self)
  end
  
  # call-seq:
  #   elem.classes = [sym, ...] -> array
  # 
  def classes=(ary)
    `for(var result=[],i=0,l=ary.length;i<l;++i){result.push(ary[i].__value__);}`
    `this.__native__.className=result.join(' ')`
    return ary
  end
  
  # call-seq:
  #   elem.clear_styles -> elem
  # 
  def clear_styles
    `this.__native__.style.cssText=''`
    return self
  end
  
  # call-seq:
  #   elem.get_property(sym) -> object or nil
  # 
  def get_property(attribute)
    `var el=this.__native__,attr=attribute.__value__,key=c$Element.__keyed_attributes__[attr],bool=c$Element.__boolean_attributes__[attr]`
    `var value=key||bool?el[key||bool]:el.getAttribute(attr,2)`
    return `bool ? !!value : (value==null) ? nil : $q(value)`
  end
  
  # call-seq:
  #   elem.get_style(sym) -> object or nil
  # 
  def get_style(attribute)
    `var el=this.__native__,attr=attribute.__value__.replace(/[_-]\\D/g, function(match){return match.charAt(1).toUpperCase();}),result=el.style[attr]`
    `result===undefined?nil:$q(result)`
  end
  
  # call-seq:
  #   elem.has_class?(sym) -> true or false
  # 
  # Returns +true+ if _elem_ is class _sym_, +false+ otherwise.
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
  def html
    `$q(this.__native__.innerHTML)`
  end
  
  # call-seq:
  #   elem.html = str -> str
  # 
  def html=(str)
    `this.__native__.innerHTML=str.__value__`
    return str
  end
  
  # call-seq:
  #   elem.properties -> object
  # 
  def properties
    @properties ||= Element::Properties.new(self)
  end
  
  # call-seq:
  #   elem.remove_class(sym) -> elem
  # 
  def remove_class(sym)
    `var el=this.__native__,klass=sym.__value__`
    `el.className=el.className.replace(new(RegExp)('(^|\\\\s)'+klass+'(?:\\\\s|$)'),'$1')`
    return self
  end
  
  # call-seq:
  #   elem.remove_classes(sym, ...) -> elem
  # 
  def remove_classes(*args)
    args.each {|x| self.remove_class(x) }
    return self
  end
  
  # call-seq:
  #   elem.remove_property(sym) -> elem
  # 
  def remove_property(attribute)
    `var el=this.__native__,attr=attribute.__value__,bool=c$Element.__boolean_attributes__[attr],key=c$Element.__boolean_attributes__[attr]||bool`
    `key ? el[key]=bool?false:'' : el.removeAttribute(attr)`
    return self
  end
  
  # call-seq:
  #   elem.remove_properties(sym, ...) -> elem
  # 
  def remove_properties(*args)
    args.each {|x| self.remove_property(x) }
    return self
  end
  
  # call-seq:
  #   elem.remove_style(sym) -> elem
  # 
  def remove_style(attribute)
    `var attr=attribute.__value__.replace(/[_-]\\D/g, function(match){return match.charAt(1).toUpperCase();})`
    `this.__native__.style[attr]=null`
    return self
  end
  
  # call-seq:
  #   elem.remove_styles(sym, ...) -> elem
  # 
  def remove_styles(*args)
    args.each {|x| self.remove_style(x) }
    return self
  end
  
  # call-seq:
  #   elem.set_property(sym, value) -> elem
  # 
  def set_property(attribute, value)
    `var el=this.__native__,attr=attribute.__value__,bool=c$Element.__boolean_attributes__[attr],key=c$Element.__boolean_attributes__[attr]||bool`
    `key ? el[key]=bool?$T(value):value : el.setAttribute(attr,''+value)`
    return self
  end
  
  # call-seq:
  #   elem.set_properties(hash) -> elem
  # 
  def set_properties(hash)
    hash.each {|k,v| self.set_property(k,v) }
    return self
  end
  
  # call-seq:
  #   elem.set_style(sym, value) -> elem
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
  #   elem.set_styles(hash) -> elem
  # 
  def set_styles(hash)
    hash.each {|k,v| self.set_style(k,v) }
    return self
  end
  
  # call-seq:
  #   elem.style -> string
  # 
  def style
    `$q(this.__native__.style.cssText)`
  end
  
  # call-seq:
  #   elem.style = str -> str
  # 
  def style=(str)
    `this.__native__.style.cssText=str.__value__`
    return str
  end
  
  # call-seq:
  #   elem.styles -> object
  # 
  def styles
    @styles ||= Element::Styles.new(self)
  end
  
  # call-seq:
  #   elem.text -> string
  # 
  def text
    `$q(#{trident?} ? this.__native__.innerText : this.__native__.textContent)`
  end
  
  # call-seq:
  #   elem.text = str -> str
  # 
  def text=(str)
    trident? ? `this.__native__.innerText=str.__value__` : `this.__native__.textContent=str.__value__`
    return str
  end
  
  # call-seq:
  #   elem.toggle_class(sym) -> elem
  # 
  def toggle_class(sym)
    self.has_class?(sym) ? self.remove_class(sym) : self.add_class(sym);
    return self
  end
  
  # Element::Classes
  # note: These are accessor objects; they don't persist the data they refer to
  class Classes
    def initialize(element) # :nodoc:
      @element = element
    end
    
    # call-seq:
    #   classes << sym -> classes
    # 
    def <<(sym)
      `c$Element.prototype.m$add_class.call(#{@element},sym)`
      return self
    end
    
    # call-seq:
    #   classes.include?(sym) -> true or false
    # 
    def include?(sym)
      `c$Element.prototype.m$has_class_bool.call(#{@element},sym)`
    end
    
    # call-seq:
    #   classes.toggle(sym) -> element
    # 
    def toggle(sym)
      `c$Element.prototype.m$toggle_class.call(#{@element},sym)`
      return @element
    end
  end
  
  # Element::Properties
  # note: These are accessor objects; they don't persist the data they refer to
  class Properties
    def initialize(element) # :nodoc:
      @element = element
    end
    
    # call-seq:
    #   properties[sym] -> object
    # 
    def [](attribute)
      `c$Element.prototype.m$get_property.call(#{@element},attribute)`
    end
    
    # call-seq:
    #   properties[sym] = value -> value
    # 
    def []=(attribute,value)
      `c$Element.prototype.m$set_property.call(#{@element},attribute,value)`
    end
    
    # call-seq:
    #   properties.delete(sym) -> object
    # 
    def delete(attribute)
      `c$Element.prototype.m$remove_property.call(#{@element},attribute)`
    end
    
    # call-seq:
    #   properties.set?(sym) -> true or false
    # 
    def set?(attribute)
      `$T(c$Element.prototype.m$get_property.call(#{@element},attribute))`
    end
    
    # call-seq:
    #   properties.update(sym) -> properties
    # 
    def update(hash)
      `c$Element.prototype.m$set_properties.call(#{@element},hash)`
      return self
    end
  end
  
  # Element::Styles
  # note: These are accessor objects; they don't persist the data they refer to
  class Styles
    def initialize(element) # :nodoc:
      @element = element
    end
    
    # call-seq:
    #   styles[sym] -> object
    # 
    def [](attribute)
      `c$Element.prototype.m$get_style.call(#{@element},attribute)`
    end
    
    # call-seq:
    #   styles[sym] = value -> value
    # 
    def []=(attribute, value)
      `c$Element.prototype.m$set_style.call(#{@element},attribute,value)`
    end
    
    # call-seq:
    #   styles.clear -> styles
    # 
    def clear
      `c$Element.prototype.m$clear_styles.call(#{@element})`
    end
    
    # call-seq:
    #   styles.delete(sym) -> object
    # 
    def delete(attribute)
      `c$Element.prototype.m$remove_style.call(#{@element},attribute)`
    end
    
    # call-seq:
    #   styles.set?(sym) -> true or false
    # 
    def set?(attribute)
      `$T(c$Element.prototype.m$get_style.call(#{@element},attribute))`
    end
    
    # call-seq:
    #   styles.update(sym) -> styles
    # 
    def update(hash)
      `c$Element.prototype.m$set_styles.call(#{@element},hash)`
      return self
    end
  end
end
