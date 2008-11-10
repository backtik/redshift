# The +Browser+ module contains methods for checking the current platform and
# rendering engine.
# 
module Browser
  `var b = c$Browser`
  `b.__platform__=(window.orientation==undefined ? (navigator.platform.match(/mac|win|linux/i)||['other'])[0].toLowerCase() : 'ipod')`
  `b.__xpath__=!!(document.evaluate)`
  `b.__air__=!!(window.runtime)`
  `b.__query__=!!(document.querySelector)`
  `if(window.opera){b.__engine__='presto';b.__version__=(arguments.callee.caller ? 960 : (document.getElementsByClassName ? 950 : 925));}`
  `if(window.ActiveXObject){b.__engine__='trident';b.__version__=(window.XMLHttpRequest ? 5 : 4);}`
  `if(!navigator.taintEnabled){b.__engine__='webkit';b.__version__=(b.__xpath__ ? (b.__query__ ? 525 : 420) : 419);}`
  `if(document.getBoxObjectFor!=undefined){b.__engine__='gecko';b.__version__=(document.getElementsByClassName ? 19 : 18);}`
  
  # call-seq:
  #   Browser.engine -> hash
  # 
  # Returns a hash containing the name and version of the current rendering
  # engine.
  # 
  #   Browser.engine    #=> {:name => "gecko", :version => 19}
  # 
  def self.engine
    {:name => `$q(c$Browser.__engine__||'unknown')`, :version => `c$Browser.__version__?c$Browser.__version__:0`}
  end
  
  # call-seq:
  #   Browser.platform -> string
  # 
  # Returns the name of the current platform as a string.
  # 
  #   Browser.platform    #=> "mac"
  # 
  def self.platform
    `$q(c$Browser.__platform__)`
  end
  
  # The +Features+ module mixes in methods to check for browser features such
  # as XPath and Adobe AIR.
  # 
  module Features
    # call-seq:
    #   xpath? -> true or false
    # 
    # Returns +true+ if XPath is available, +false+ otherwise.
    # 
    def xpath?
      `c$Browser.__xpath__`
    end
    
    # call-seq:
    #   air? -> true or false
    # 
    # Returns +true+ if Adobe AIR is available, +false+ otherwise.
    # 
    def air?
      `c$Browser.__air__`
    end
    
    # call-seq:
    #   query? -> true or false
    # 
    # Returns +true+ if the W3C Selectors API is available, +false+ otherwise.
    #
    def query?
      `c$Browser.__query__`
    end
  end
  
  # The +Engine+ module mixes in methods to check the current browser's
  # rendering engine and its version.
  # 
  module Engine
    # call-seq:
    #   gecko?      -> true or false
    #   gecko?(num) -> true or false
    # 
    # Returns +true+ if the current browser is Firefox. Optionally checks for
    # version _num_.
    # 
    #   gecko?        #=> true
    #   gecko?(18)    #=> false
    # 
    def gecko?(version)
      `c$Browser.__engine__=='gecko'&&(version ? c$Browser.__version__==version : true)`
    end
    
    # call-seq:
    #   presto?      -> true or false
    #   presto?(num) -> true or false
    # 
    # Returns +true+ if the current browser is Opera. Optionally checks for
    # version _num_.
    # 
    #   presto?         #=> true
    #   presto?(925)    #=> false
    # 
    def presto?(version)
      `c$Browser.__engine__=='presto'&&(version ? c$Browser.__version__==version : true)`
    end
    
    # call-seq:
    #   trident?      -> true or false
    #   trident?(num) -> true or false
    # 
    # Returns +true+ if the current browser is Internet Explorer. Optionally
    # checks for version _num_.
    # 
    #   trident?      #=> true
    #   trident?(4)   #=> false
    # 
    def trident?(version)
      `c$Browser.__engine__=='trident'&&(version ? c$Browser.__version__==version : true)`
    end
    
    # call-seq:
    #   webkit?      -> true or false
    #   webkit?(num) -> true or false
    # 
    # Returns +true+ if the current browser is Safari, Mobile Safari, or
    # Google Chrome. Optionally checks for version _num_.
    # 
    #   webkit?         #=> true
    #   webkit?(419)    #=> false
    # 
    def webkit?(version)
      `c$Browser.__engine__=='webkit'&&(version ? c$Browser.__version__==version : true)`
    end
  end
end

include Browser::Engine
include Browser::Features
