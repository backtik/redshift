# Browser represets the browser object and is used to store properties about the user's browser.  The properties are stored
# in named Hashes inside of Browser
# Browser::Engine[:name] returns the name of engine as a string. Will be one of 'presto', 'trident', 'webkit', 'gecko'
# Browser::Engine[:version] returns the version of browser engine as a integer
# Browser::Platform[:name] returns the platform name as a string. Will be one of 'mac', 'win', 'linux', 'other'
# Browser::Features[:xpath] true if the browser has xpath abilities
# Browser::Features[:air] true if the browser has air abilities
# Browser::Features[:xhr] true if the browser has xhr abilities
# Browser::Plugins
# Browser::Request returns a new object for XML HTTP Requests using the method supported by the browser
module Browser
  Engine   = {:name => 'unknown', :version => '' }
	Platform = {:name => `$q((navigator.platform.match(/mac|win|linux/i) || ['other'])[0].toLowerCase())` }
	Features = {:xpath => `!!(document.evaluate)`, :air => `!!(window.runtime)` }
	Plugins  = {}
	Request  = `typeof(ActiveXObject)=='undefined' ? new XMLHttpRequest : new ActiveXObject('MSXML2.XMLHTTP')`
  
  # Browser sniffing. Runs once at library load time to populate
  # singleton Browser class object with correct ::Engine data
  if `window.opera`
    Engine = {:name => 'presto', :version => (`document.getElementsByClassName`) ? 950 : 925}
  elsif `window.ActiveXObject`
    Engine = {:name => 'trident', :version => (`window.XMLHttpRequest`) ? 5 : 4 }
  elsif `!navigator.taintEnabled`
    Engine = {:name => 'webkit', :version => (Browser::Features[:xpath]) ? 420 : 419}
  elsif `document.getBoxObjectFor != null`
    Engine = {:name => 'gecko', :version => (`document.getElementsByClassName`) ? 19 : 18}
  end

  Platform[:name] = 'ipod' if defined? `window.orientation`
  Features[:xhr]  = !!Browser::Request
  
  # call-seq:
  #    Engine.presto? -> true or false
  #
  # returns true if the Browser::Engine is presto (browser is Opera)
  #
  def Engine.presto?
    Engine[:name] == 'presto'
  end
  
  # call-seq:
  #    Engine.trident? -> true or false
  #
  # returns true if the Browser::Engine is trident (browser is Internet Explorer)
  #
  def Engine.trident?
    Engine[:name] == 'trident'
  end
  
  # call-seq:
  #    Engine.webkit? -> true or false
  #
  # returns true if the Browser::Engine is webkit (browser is Safari, Mobile Safari, Google Chrome)
  #
  def Engine.webkit?
    Engine[:name] == 'trident'
  end
  
  # call-seq:
  #    Engine.gecko? -> true or false
  #
  # returns true if the Browser::Engine is gecko (browser is Firefox)
  #
  def Engine.gecko?
    Engine[:name] == 'gecko'
  end
end