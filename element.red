require 'document.red'
require 'user_events.red'
require 'code_events.red'

class Element
  `window.$E=function(element){if(element==null){return nil;};var E=c$Element.m$new(null);E.__native__=element;return E;}`
  
  include UserEvents
  include CodeEvents
  
  def self.destroy(elem) # :nodoc
    `var el = elem.__native__ || elem`
    `c$Element.m$empty(el);`
    `c$Element.m$remove(el);`
    return true
  end
  
  def self.empty(elem) # :nodoc
    `var el = elem.__native__ || elem`
    `for (var i = 0, c = el.childNodes, l = c.length; i < l; i++){
      c$Element.m$destroy(c[i]);
    };`
    return true
  end
  
  def self.remove(elem) # :nodoc
    `var el = elem.__native__ || elem`
    `(el.parentNode) ? el.parentNode.removeChild(el) : this`
  end
  
  # call-seq:
  #   Element.new(tag, attributes = {}) -> element
  # 
  def initialize(tag, attributes = {})
    `if(!tag){ return nil; }`
    `this.__native__ = document.createElement(tag.__value__)`
  end
  
  # call-seq:
  #   elem[str] -> array
  # 
  # *args?
  # 
  def [](expression, *args)
    `if (expression.__value__.match(/^#[a-zA-z_]*$/) && #{args.empty?}){return #{self}.__native__.getElementById(expression.__value__.replace('#',''));}`
    expression = expression.split(',')
    items = []
    `for (var i = 0, l = expression.length, local = {}; i < l; i++){
      var selector = expression[i].__value__, elements = Selectors.Utils.search(#{self}.__native__, selector, local);
      elements = Array.fromCollection(elements);
      items = (i == 0) ? elements : items.concat(elements);     
    }`
    return items
  end
  
  # call-seq:
  #   elem.children -> array
  # 
  # Returns the array of _elem_'s child elements on the DOM tree.
  # 
  #   <div id="container">
  #     <div id="a_element"></div>
  #       <div id="a_inner_element"></div>
  #     </div>
  #     <div id="b_element"></div>
  #   </div>
  #   
  #   Document['#container'].children   #=> [#<Element: DIV id="a_element">, #<Element: DIV id="b_element">]
  #
  def children(match_selector = nil)
    Document.walk(self, 'nextSibling', 'firstChild', match_selector, true)
  end
  
  # call-seq:
  #   elem.destroy! -> true or false
  # Removes the element from the page and the DOM, destroys the element object, the native object,
  # any attached event listeners, and frees their memory location. Returns +true+ if successful, +false+ otherwise.
  def destroy!
    Element.destroy(self)
    return true
  end
  
  def document
    `this.__native__.ownerDocument`
  end
  
  # call-seq:
  #   elem.empty! -> true or false
  # Removes every child element from elem
  # 
  def empty!
    Element.empty(self)
    return self
  end
  
  # call-seq:
  #   elem.first_child -> element
  # 
  # Returns the first child element of _elem_ on the DOM tree, or +nil+ if no
  # such element is found.
  # 
  #   <div id="container">
  #     <div id="a_element"></div>
  #     <div id="b_element"></div>
  #     <div id="c_element"></div>
  #     <div id="d_element"></div>
  #   </div>
  #   
  #   Document['#container'].first_child #=> #<Element: DIV id="a_element">
  # 
  def first_child(match_selector = nil)
    Document.walk(self, 'nextSibling', 'firstChild', match_selector, false)
  end
  
  # call-seq:
  #   elem.insert(other, sym = :bottom) -> elem
  # 
  # Returns _elem_ with _other_ inserted at location _sym_.
  # 
  # Inserting into <tt>:bottom</tt> (default location):
  # 
  #   <div id='a_element'>
  #     <div id='b_element'></div>
  #     <div id='c_element'></div>
  #   </div>
  #   <div id='d_element'></div>
  #   
  #   elem  = Document['#a_element']
  #   other = Document['#d_element']
  #   elem.insert(other)
  # 
  # produces:
  # 
  #   <div id='a_element'>
  #     <div id='b_element'></div>
  #     <div id='c_element'></div>
  #     <div id='d_element'></div>
  #   </div>
  # 
  # Inserting into <tt>:top</tt>:
  # 
  #   <div id='a_element'>
  #     <div id='b_element'></div>
  #     <div id='c_element'></div>
  #   </div>
  #   <div id='d_element'></div>
  #   
  #   elem  = Document['#a_element']
  #   other = Document['#d_element']
  #   elem.insert(other, :top)
  # 
  # produces:
  # 
  #   <div id='a_element'>
  #     <div id='d_element'></div>
  #     <div id='b_element'></div>
  #     <div id='c_element'></div>
  #   </div>
  # 
  # Inserting <tt>:before</tt>:
  # 
  #   <div id='a_element'>
  #     <div id='b_element'></div>
  #     <div id='c_element'></div>
  #   </div>
  #   <div id='d_element'></div>
  #   
  #   elem  = Document['#a_element']
  #   other = Document['#d_element']
  #   elem.insert(other, :before)
  # 
  # produces:
  # 
  #   <div id='d_element'></div>
  #   <div id='a_element'>
  #     <div id='b_element'></div>
  #     <div id='c_element'></div>
  #   </div>
  # 
  def insert(element, where = :bottom)
    self.send("insert_#{where.to_s}", element)
    return self
  end
  
  def insert_after(element) # :nodoc
    `if (!element.parentNode) return`
    `next = #{self}.__native__.nextSibling`
    `(next) ? #{self}.__native__.parentNode.insertBefore(#{element}.__native__, next) : #{self}__native__.parentNode.appendChild(#{element}.__native__)`
    return true
  end
  
  def insert_before(element) # :nodoc:
    `if (#{self}.__native__.parentNode) #{self}.__native__.parentNode.insertBefore(#{element}.__native__, #{self}.__native__)`
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
  
  # call-seq:
  #   elem.inspect -> string
  # 
  # Returns a string representation of _elem_ including its tag name, classes,
  # and id.
  # 
  #   <div style="width:300px" id="a_element" class="draggable container">
  #   
  #   Document['#a_element'].inspect    #=> "#<Element: DIV id=\"a_element\" class=\"draggable container\">"
  # 
  def inspect
    attributes = [`$q(this.__native__.tagName.toUpperCase())`]
    attributes << `$q('id="'+this.__native__.id+'"')` if `this.__native__.id!==''`
    attributes << `$q('class="'+this.__native__.className+'"')` if `this.__native__.className!==''`
    "#<Element: %s>" % attributes.join(' ')
  end
  
  # call-seq:
  #   elem.is_body? -> true or false
  # 
  # Returns +true+ if the element is the body element, +false+ otherwise.
  # 
  #   Document['#my_div'].is_body?   #=> false
  #   Document.body.is_body?         #=> true
  #
  def is_body?
    `(/^(?:body|html)$/i).test(#{self}.__native__.tagName)`
  end
  
  # call-seq:
  #   elem.last_child -> element or nil
  # 
  # Returns the last child element of _elem_ on the DOM tree, or +nil+ if no
  # such element is found.
  # 
  #   <div id="container">
  #     <div id="a_element"></div>
  #     <div id="b_element"></div>
  #     <div id="c_element"></div>
  #     <div id="d_element"></div>
  #   </div>
  #   
  #   Document['#container'].last_child   #=> #<Element: DIV id="d_element">
  # 
  def last_child(match_selector = nil)
    Document.walk(self, 'previousSibling', 'lastChild', match_selector, false)
  end
  
  # call-seq:
  #   elem.next_element -> element or nil
  # 
  # Returns the sibling element immediately following _elem_ on the DOM tree,
  # or +nil+ if no such element is found.
  # 
  #   <div id='container'>
  #     <div id='a_element'></div>
  #     <div id='b_element'></div>
  #     <div id='c_element'></div>
  #     <div id='d_element'></div>
  #   </div>
  #   
  #   Document['#b_element'].next_element   #=> #<Element: DIV id="c_element">
  # 
  def next_element(match_selector = nil)
    Document.walk(self, 'nextSibling', nil, match_selector, false)
  end
  
  # call-seq:
  #   elem.next_elements -> array
  # 
  # Returns the array of sibling elements that follow _elem_ on the DOM tree.
  # 
  #   <div id='container'>
  #     <div id='a_element'></div>
  #     <div id='b_element'></div>
  #     <div id='c_element'></div>
  #     <div id='d_element'></div>
  #   </div>
  #   
  #   elem = Document['#b_element']   #=> #<Element: DIV id="b_element">
  #   elem.previous_elements          #=> [#<Element: DIV id="c_element">, #<Element: DIV id="d_element">]
  # 
  def next_elements(match_selector = nil)
    Document.walk(self, 'nextSibling', nil, match_selector, true)
  end
  
  # call-seq:
  #   elem.parent -> element or nil
  #
  # Returns the parent element of _elem_ on the DOM tree, or +nil+ if no such
  # element is found.
  # 
  #   <div id="container">
  #     <div id="a_element"></div>
  #     <div id="b_element"></div>
  #     <div id="c_element"></div>
  #     <div id="d_element"></div>
  #   </div>
  #   
  #   Document['#c_element'].parent   #=> #<Element: DIV id="container">
  #   Document.body.parent            #=> #<Element: HTML>
  #   Document.body.parent.parent     #=> nil
  # 
  def parent(match_selector = nil)
    Document.walk(self, 'parentNode', nil, match_selector, false)
  end
  
  # call-seq:
  #   elem.parents -> array
  # 
  # Returns the array of _elem_'s ancestors on the DOM tree.
  # 
  #   <div id='container'>
  #     <div id='a_element'></div>
  #     <div id='b_element'>
  #       <div id='b_inner_element'></div>
  #     </div>
  #     <div id='c_element'></div>
  #     <div id='d_element'></div>
  #   </div>
  #   
  #   Document['#b_inner_element'].parents    #=> [#<Element: DIV id="b_element">, #<Element: DIV id="container">, <Element: BODY>, <Element: HTML>]
  #   Document.html.parents                   #=> []
  # 
  def parents(match_selector = nil)
    Document.walk(self, 'parentNode', nil, match_selector, true)
  end
  
  # call-seq:
  #   elem.previous_element -> element or nil
  # 
  # Returns the sibling element immediately preceding _elem_ on the DOM tree,
  # or +nil+ if no such element is found.
  # 
  #   <div id='container'>
  #     <div id='a_element'></div>
  #     <div id='b_element'></div>
  #     <div id='c_element'></div>
  #     <div id='d_element'></div>
  #   </div>
  #   
  #   Document['#b_element'].previous_element   #=> #<Element: DIV id="a_element">
  # 
  def previous_element(match_selector = nil)
    Document.walk(self, 'previousSibling', nil, match_selector, false)
  end
  
  # call-seq:
  #   elem.previous_elements -> array
  # 
  # Returns the array of sibling elements that precede _elem_ on the DOM tree.
  # 
  #   <div id='container'>
  #     <div id='a_element'></div>
  #     <div id='b_element'></div>
  #     <div id='c_element'></div>
  #     <div id='d_element'></div>
  #   </div>
  #   
  #   elem = Document['#c_element']   #=> #<Element: DIV id="c_element">
  #   elem.previous_elements          #=> [#<Element: DIV id="a_element">, #<Element: DIV id="b_element">]
  # 
  def previous_elements(match_selector = nil)
    Document.walk(self, 'previousSibling', nil, match_selector, true)
  end
  
  # call-seq:
  #   elem.empty! -> elem
  # 
  # Removes the element and all of its children elements from the page
  # 
  def remove!
    Element.remove(self)
    return self
  end
end