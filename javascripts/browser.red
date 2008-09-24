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