# The +Browser+ module contains methods for checking the current platform and
# rendering engine.
# 
module Browser
  Plugins = {}
  
  # call-seq:
  #   Browser.engine -> hash
  # 
  # Returns a hash containing the name and version of the current rendering
  # engine.
  # 
  #   Browser.engine    #=> {:name => "gecko", :version => 19}
  # 
  def self.engine
    {:name => Engine.instance_variable_get('@name'), :version => Engine.instance_variable_get('@version')}
  end
  
  # call-seq:
  #   Browser.platform -> string
  # 
  # Returns the name of the current platform as a string.
  # 
  #   Browser.platform    #=> "mac"
  # 
  def self.platform
    @platform ||= `$q(window.orientation==undefined?(navigator.platform.match(/mac|win|linux/i)||['other'])[0].toLowerCase():'ipod')`
  end
  
  # The +Features+ module mixes in methods to check for browser features such
  # as XPath and Adobe AIR.
  # 
  module Features
    @xpath = `!!(document.evaluate)`
    @air   = `!!(window.runtime)`
    @query = `!!(document.querySelector)`
    
    # call-seq:
    #   xpath? -> true or false
    # 
    # Returns +true+ if XPath is available, +false+ otherwise.
    # 
    def xpath?
      Features.instance_variable_get('@xpath')
    end
    
    # call-seq:
    #   air? -> true or false
    # 
    # Returns +true+ if Adobe AIR is available, +false+ otherwise.
    # 
    def air?
      Features.instance_variable_get('@air')
    end
    
    # call-seq:
    #   query? -> true or false
    # 
    # Returns +true+ if the W3C Selectors API is available, +false+ otherwise.
    #
    def query?
      Features.instance_variable_get('@query')
    end
  end
  
  # The +Engine+ module mixes in methods to check the current browser's
  # rendering engine and its version.
  # 
  module Engine
    if `window.opera`
      @name    = 'presto'
      @version = `document.getElementsByClassName` ? 950 : 925
    elsif `window.ActiveXObject`
      @name    = 'trident'
      @version = `window.XMLHttpRequest` ? 5 : 4
    elsif `!navigator.taintEnabled`
      @name    = 'webkit'
      @version = Browser::Features[:xpath] ? (Browser::Features[:query] ? 525 : 420) : 419
    elsif `document.getBoxObjectFor != null`
      @name    = 'gecko'
      @version = `document.getElementsByClassName` ? 19 : 18
    else
      @name    = 'unknown'
      @version = 0
    end
    
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
      self.browser?('gecko', version)
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
      self.browser?('presto', version)
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
      self.browser?('trident', version)
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
      self.browser?('webkit', version)
    end
    
    def browser?(name, version) # :nodoc:
      Engine.instance_variable_get('@name') == name && (version ? Engine.instance_variable_get('@version') == version : true)
    end
  end
end

include Browser::Engine
include Browser::Features
