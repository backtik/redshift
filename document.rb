require 'selectors'
require 'window'

# The +Document+ object enables access to top-level HTML elements like
# <i><head></i>, <i><html></i>, and <i><body></i>.
# 
# +Document+ also provides "DOM-ready" functionality with
# <tt>Document.ready?</tt> and element-finding functionality through the
# powerful <tt>Document.[]</tt> method.
# 
module Document
  `document.head=document.getElementsByTagName('head')[0]`
  `document.html=document.getElementsByTagName('html')[0]`
  `document.window=(document.defaultView||document.parentWindow)`
  `c$Document.__native__= document`
  
  # call-seq:
  #   Document["#id"]      -> element or nil
  #   Document["selector"] -> [element, ...]
  #   Document[str, ...]   -> [element, ...]
  # 
  # The first form returns the +Element+ identified by the id <i>str</i> (e.g.
  # <i>'#my_id'</i>), or +nil+ if no such element is found. The second form
  # returns the array of elements identified by the selector <i>str</i>.
  # The third form returns the array of elements found by calling
  # <tt>Document.[]</tt> on each arg. The fourth form returns _element_
  # unchanged.
  # 
  # The first form returns the +Element+ identified by the string
  # <i>"#id"</i>, or +nil+ if no such element is found.
  # 
  #   Document['#content']    #=> #<Element: DIV id="content">
  # 
  # The second form returns the array of +Element+ objects that match the
  # string <i>"selector"</i>, which takes the format of a CSS3 selector. See
  # http://www.w3.org/TR/css3-selectors/ for details.
  # 
  #   
  # 
  # Available Selectors
  # Document[str] in its second form takes a selector string and scans the document
  # returing an array of any elements that match the selector string. 
  # 
  # The selectors string takes the format of a CSS3 selector: http://www.w3.org/TR/css3-selectors/
  # 
  # Class Selector
  # Returns an array of elements that have the specified class name
  # Document['.my_class'] #=> [#<Element: DIV class="my_class">, #<Element: DIV class="my_class">, #<Element: SPAN class="my_class">]
  # 
  # Tag Selector
  # Returns an array of elements that have the specified tag
  # Document['a'] #=> [#<Element: A href="/foo/bar">, #<Element: A href="/foo/baz">, #<Element: A href="/foo/bat">]
  # 
  def self.[](*args)
    if args.length == 1
      return nil unless args[0]
      return self.find_by_string(args[0])
    else
      args.map do |str|
        Document[str]
      end.compact
      #return self.find_many_with_array(args.unshift(obj))
    end
  end
  
  # call-seq:
  #   Document.body -> element
  # 
  # Returns the <i><body></i> element of the current page.
  # 
  #   Document.body   #=> #<Element: BODY>
  # 
  def self.body
    `$E(document.body)`
  end
  
  # call-seq:
  #   Document.execute_js(str) -> str
  # 
  # Executes _str_ as JavaScript, then returns _str_.
  # 
  def self.execute_js(str)
    return str if str == ''
    if `window.execScript`
      `window.execScript(str.__value__)`
    else
      `scriptElement = document.createElement('script')`
      `scriptElement.setAttribute('type','text/javascript')`
      `scriptElement.text = str`
      `document.head.appendChild(scriptElement)`
      `document.head.removeChild(scriptElement)`
    end
    return str
  end
  
  # call-seq:
  #   Document.head -> element
  # 
  # Returns the <i><head></i> element of the current page.
  # 
  #   Document.head   #=> #<Element: HEAD>
  # 
  def self.head
    `$E(document.head)`
  end
  
  # call-seq:
  #   Document.html -> element
  # 
  # Returns the <i><html></i> element of the current page.
  # 
  #   Document.html   #=> #<Element: HTML>
  # 
  def self.html
    `$E(document.html)`
  end
  
  # call-seq:
  #   Document.ready? { block } -> nil
  # 
  # When the DOM is finished loading, executes the given _block_, then returns
  # +nil+.
  # 
  #   Document.ready? do
  #     puts self.title
  #   end
  # 
  # produces:
  # 
  #   "RDoc Documentation"
  # 
  def self.ready?(&block)
    @proc = block
    `document.addEventListener('DOMContentLoaded', function(){document.__loaded__=true;#{@proc.call};}.m$(this), false)`
    return nil
  end
  
  # call-seq:
  #   Document.title -> string
  # 
  # Returns the title of the current page.
  # 
  #   Document.title    #=> "RDoc Documentation"
  # 
  def self.title
    `$q(document.title)`
  end
  
  # Uses the Selector library to find native elements and retrun an array of extended elements
  def self.find_all_by_selector(selector) # :nodoc:
    # `Array.fromCollection(Selectors.Utils.search(document, selector.__value__, {}));`
    `Array.fromCollection(Sizzle(selector.__value__));`
  end
  
  # Uses the browser's native getElementById to find an element. Returns an extended element.
  def self.find_by_id(str) # :nodoc:
    `$E(document.getElementById(str.__value__))`
  end
  
  # Finds an element from a provided string. If the string is a represents a single id ('#my_id') calls
  # self.find_all_by_id, otherwise calls self.find_all_by_selector
  def self.find_by_string(str) # :nodoc:
    `str.__value__.match(/^#[a-zA-z_]*$/)` ? self.find_by_id(`$q(str.__value__.replace('#',''))`) : self.find_all_by_selector(str)
  end
  
  def self.find_many_with_array(ary) # :nodoc:
    `for(var i=0,l=ary.length,result=[];i<l;++i){var el=#{Document[`ary[i]`]};if($T(el)){result.push(el);};}`
    return `result`.flatten
  end
  
  # Walks the DOM from a particular element.  The first step it talks in the walk with either
  # be the specified start_relation or the specified path.  If 'all' is set to false, the walk
  # will termiante and return the single element. Otherwise, it will continue the walk until it 
  # has reached the end of the specified path.
  # The walk will then termiante and return an array of all elements on the path.
  #
  # if an optional <tt>match_selector<tt> is provided, only element(s) that match
  # the selector can be returned
  # 
  # Examples:
  # Document.walk(my_element, 'parentNode', nil, nil, false)
  # will go down the parentNode path of my_element, starting at the my_element, and
  # return just a single element
  # 
  # Document.walk(my_element, 'parentNode', nil, nil, true)
  # will go down the parentNode path of my_element, starting at my_element, and 
  # return an array of all elements on the parentNode path
  # 
  # Document.walk(my_element, 'nextSibling', 'firstChild', nil, true)
  # will go down the nextSibling path of my_element, starting at my_element's firstChild
  # and return an array of all elements on the nextSibling path from that starting point.
  # 
  # Document.walk(my_element, 'nextSibling', 'firstChild', '.my_class', true)
  # will go down the nextSibling path of my_element, starting at my_element's firstChild
  # and return an array of all elements on the nextSibling path from that starting point that
  # have the class 'my_class'
  # 
  def self.walk(element, path, startRelation, matchSelector, all) # :nodoc
    `if(startRelation){startRelation = startRelation.__value__;};
    var el = element.__native__[startRelation || path.__value__],elements = [];
    while (el){
      if (el.nodeType == 1 && (#{!matchSelector} || Element.match(el, #{matchSelector}))){
        if (!all) {return $E(el);}
        elements.push($E(el));
      }
      el = el[path.__value__];
    }`
    return `(all) ? elements : nil`
  end
  
  def self.window # :nodoc:
    Window
  end
  
  def self.document # :nodoc
    self
  end
end
