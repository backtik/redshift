# # Singleton object to represent the browser, normalized for browser differences
module Browser
  Engine   = {:name => 'unknown', :version => '' }
	Platform = {:name => `(navigator.platform.match(/mac|win|linux/i) || ['other'])[0].downcase` }
	Features = {:xpath => `!!(document.evaluate)`, :air => `!!(window.runtime)` }
	Plugins  = {}
  # Request  = XMLHttpRequest.new rescue ActiveXObject.new('MSXML2.XMLHTTP')
end

# Browser sniffing. Runs once at library load time to populate
# singleton Browser class object with correct ::Engine data
if `window.opera`
  Browser::Engine = {:name => 'presto', :version => (`document.getElementsByClassName`) ? 950 : 925}
elsif `window.ActiveXObject`
  Browser::Engine = {:name => 'trident', :version => (`window.XMLHttpRequest`) ? 5 : 4 }
elsif `!navigator.taintEnabled`
  Browser::Engine = {:name => 'webkit', :version => (Browser::Features[:xpath]) ? 420 : 419}
elsif `document.getBoxObjectFor` != nil
  Browser::Engine = {:name => 'gecko', :version => (`document.getElementsByClassName`) ? 19 : 18}
end

Browser::Platform[:name] = 'ipod' if defined? `window.orientation`
Browser::Features[:xhr]  = !!Browser::Request

module Browser
  # add convinience methods to the Browser::Engine
  def Engine.presto?
    self[:name] == 'presto'
  end
  
  def Engine.trident?
    self[:name] == 'trident'
  end
  
  def Engine.webkit?
    self[:name] == 'trident'
  end
  
  def Engine.gecko?
    self[:name] == 'gecko'
  end
end

# Singleton class object to represent the document, normalized for browser differences
# Document[string]
#   Document['#foo']
#     find element with id of foo
#     returns an Element::Extended object
#   Document['a']
#     finds all elements of tag a
#     returns array of Element::Extended objects
#   Document['a.special']
#      finds all elements of tag a with class 'special'
#
# Document[element object]
#     find the extist extended object
#

class DocumentClass
  # delegate :window, :inner_width, :inner_height, :outer_width, :inner_width
  # :screen_x, :screen_y, :page_x_offset, :page_y_offset, :scroll_x, :scroll_y,
  # :scroll_max_x, :scroll_max_y, :parent, :to => :native_document
  
  def initialize(doc)
    @native_document = doc
  end
  
  def native
    @native_document
  end
  
  def [](element)
    case element.class
    when ::String
      return self.find_by_string(element)
    when ::Array
      return self.find_many_with_array(element)
    when ::Element::Extended
      return element
    when ::Object
      return self.find_by_native_element(element)
    else
      return nil
    end
  end
  
  def find_by_string(string)
    `string.toString().match(/^#[a-zA-z_]*$/)` ? self.find_by_id(`string.toString().replace('#','')`) : self.find_all_by_selector(string)
  end
  
  def find_by_id(id)
    id = `document.getElementById(id)`
    return id ? self.find_by_native_element(id) : nil
  end
  # 
  # def find_all_by_selector(selector)
  #  return this.document.get_elements(selector) if (`arguments.length == 1 && typeof selector == 'string'`)
  # end
  # 
  def find_by_native_element(element)
    ::Element::Extended.new(element)
  end
  # 
  # def loaded?
  #   
  # end
end

# Initialize the Document object and make it impossible
# to initialize additional DocumentClass objects
Doc = DocumentClass.new(document)
# undef DocumentClass.initialize
# 
# Window.implement({
# 
#   $$: function(selector){
#     if (arguments.length == 1 && typeof selector == 'string') return this.document.getElements(selector);
#     var elements = [];
#     var args = Array.flatten(arguments);
#     for (var i = 0, l = args.length; i < l; i++){
#       var item = args[i];
#       switch ($type(item)){
#         case 'element': item = [item]; break;
#         case 'string': item = this.document.getElements(item, true); break;
#         default: item = false;
#       }
#       if (item) elements.extend(item);
#     }
#     return new Elements(elements);
#   },
# 
#   getDocument: function(){
#     return this.document;
#   },
# 
#   getWindow: function(){
#     return this;
#   }
# 
# });

# 
# $.element = function(el, nocash){
#   $uid(el);
#   if (!nocash && !el.$family && !(/^object|embed$/i).test(el.tagName)){
#     var proto = Element.Prototype;
#     for (var p in proto) el[p] = proto[p];
#   };
#   return el;
# };
# 
# $.object = function(obj, nocash, doc){
#   if (obj.toElement) return $.element(obj.toElement(doc), nocash);
#   return null;
# };

class Cookie
  OPTIONS = {:path => false, :domain => false, :duration => false, :secure => false, :document => ::Doc}
  
  def initialize(key, options = {})
    @key = key
    @options = options.merge(OPTIONS)
  end
  
  def write(value)
    value = `encodeURIComponent(value)`
		value += '; domain=' + @options[:domain] if (@options[:domain]) 
		value += '; path=' + @options[:path] if (@options[:path])
		if @options[:duration]
			`date = new Date()`
			`date.setTime(date.getTime() + this.options.duration * 24 * 60 * 60 * 1000)`
			 value += '; expires=' + `date.toGMTString()`
		end
		
		value += '; secure' if (@options[:secure]) 
		`#{@options[:document].native}.cookie = #{@key} + '=' + value`
		return self
  end
  
  def read
    value = `#{@options[:document].native}.cookie.match('(?:^|;)\\s*' + #{@key}.toString().escapeRegExp() + '=([^;]*)')`
		return value ? `decodeURIComponent(value[1])` : nil
  end
  
  def destroy
    Cookie.new(@key, @options.merge({:duration => -1})).write('')
		return self
  end
end

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
      property = ::Element::Properties[prop]
      # property && property.respond_to?(:set) ? property.set(self, value) : set_property(prop, value)
      property ? property.set(self, value) : self.set_property(prop, value)
      end
      return self
  	end
  	
  	def get(prop)
	  	property = Element::Properties[prop]
      # return (property && property.get) ? property.get.apply(this, Array.slice(arguments, 1)) : this.getProperty(prop);
      return (property) ? property.get(self,prop) : self.get_property(prop)
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
        
    def has_class?(name)
      !!"(`#{@native}.className`).test(name)`
    end
    
  	def add_class(name)
      # `#{@native}.className` = (`#{@native}.className` + ' ' + name) unless self.has_class?(name)
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