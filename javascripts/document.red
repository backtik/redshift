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
#     find the existing extended object
#

module Document
  NATIVE = `document`
  
  def self.delegate(*methods)
    to = methods.pop[:to]
    `for(var i=0,l=methods.length;i<l;++i){
      var a=methods[i]._value;
      f1 = this.prototype['m$'+a]=function(){console.log(arguments.callee.delegated_method);return c$DocumentClass.c$NATIVE[arguments.callee.delegated_method];};
      f1.delegated_method = a
      f2 = this.prototype['m$'+a+'Eql']=function(x){return c$DocumentClass.c$NATIVE[arguments.callee.delegated_method]=x;};
      f2.delegated_method = a
    }`
    return nil
  end
  
  delegate :title, :inner_width, :inner_height, :outer_width, :inner_width,
  :screen_x, :screen_y, :page_x_offset, :page_y_offset, :scroll_x, :scroll_y,
  :scroll_max_x, :scroll_max_y, :parent, :to => :native
  
  attr :proc
  
  `document.head=document.getElementsByTagName('head')[0]`
  
  def self.native
    `document`
  end
  
  def self.window
    `#{@native_document}.defaultView || #{@native_document}.parentWindow`
  end
  
  def self.[](element)
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
  
  def self.find_by_string(string)
    `string.toString().match(/^#[a-zA-z_]*$/)` ? self.find_by_id(`string.toString().replace('#','')`) : self.find_all_by_selector(string)
  end
  
  def self.find_by_id(id)
    id = `document.getElementById(id)`
    return id ? self.find_by_native_element(id) : nil
  end
  
  # def find_all_by_selector(selector)
  #  return this.document.get_elements(selector) if (`arguments.length == 1 && typeof selector == 'string'`)
  # end
  
  def self.find_by_native_element(element)
    ::Element::Extended.new(element)
  end
  
  def self.ready?(&block)
    @proc = block
    `document.addEventListener('DOMContentLoaded', function(){
      document.__loaded__ = true
      #{@proc.call}
    }.m$(this), false)`
  end
end
