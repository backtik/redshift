
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
# Document[element]
#     find the existing extended object
#

`function $E(element){if(element==null){return nil;};var E=c$Element.m$new();E.__native__=element;return E;}`

class Element
  def inspect
    attributes = [`$q(this.__native__.tagName.toUpperCase())`]
    attributes << `$q('id="'+this.__native__.id+'"')` if `this.__native__.id!=''`
    attributes << `$q('class="'+this.__native__.class+'"')` if `this.__native__.class`
    "<Element: %s>" % attributes.join(' ')
  end
end

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
  
  # def self.delegate(*properties) # :nodoc:
  #   to = properties.pop[:to]
  #   `for(var i=0,l=properties.length;i<l;++i){
  #     var a=properties[i].__value__,t=to.__value__;
  #     var f1=function(){var result=this['m$'+t]()[arguments.callee.__propertyName__];return result==null?nil:result;};f1.__propertyName__=a;this['m$'+a]=f1;
  #     var f2=function(x){return this['m$'+t]()[arguments.callee.__propertyName__]=x;};f2.__propertyName__=a;this['m$'+a+'Eql']=f2;
  #   }`
  #   return nil
  # end
  # 
  # delegate(:innerHeight, :innerWidth, :outerWidth, :pageXOffset,
  #          :pageYOffset, :screenX, :screenY, :scrollMaxX,
  #          :scrollMaxY, :scrollX, :scrollY, {:to => :window})
  
  # call-seq:
  #   Document[str]      -> element or nil
  #   Document[str]      -> [element, ...]
  #   Document[arg, ...] -> [element, ...]
  #   Document[element]  -> element
  # 
  # The first form returns the +Element+ identified by the id <i>str</i> (e.g.
  # <i>'#my_id'</i>), or +nil+ if no such element is found. The second form
  # returns the array of elements identified by the selector <i>str</i>. The
  # third form returns the array of elements found by calling
  # <tt>Document.[]</tt> on each arg. The fourth form returns _element_
  # unchanged.
  # 
  #   Document['#content']    #=> #<Element: DIV id="content">
  #   ...
  # 
  def self.[](obj, *args)
    if args.empty?
      case obj
      when String
        return self.find_by_string(obj)
      when Element
        return obj
      end
    else
      return self.find_many_with_array(args.unshift(obj))
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
  def Document.execute_js(str)
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
  
  def self.find_all_by_selector(selector) # :nodoc:
    # return this.document.get_elements(selector) if (`arguments.length == 1 && typeof selector == 'string'`)
    `function(ob){
      for (var i = 0, a = [], j = ob.length; i < j; i++){
        a.push($E(ob[i]))
      }
      return a
    }(Selectors.Utils.search(document, selector.__value__, {}));`
  end
  
  def self.find_by_id(str) # :nodoc:
    `$E(document.getElementById(str.__value__))`
  end
  
  def self.find_by_string(str) # :nodoc:
    `str.__value__.match(/^#[a-zA-z_]*$/)` ? self.find_by_id(`$q(str.__value__.replace('#',''))`) : self.find_all_by_selector(str)
  end
  
  def self.find_many_with_array(ary) # :nodoc:
    `for(var i=0,l=ary.length,result=[];i<l;++i){var el=#{Document[`ary[i]`]};if($T(el)){result.push(el);};}`
    return `result`.flatten
  end
  
  # def self.native # :nodoc:
  #   `document`
  # end
  
  def self.window # :nodoc:
    Window
  end
end
