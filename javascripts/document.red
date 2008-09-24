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