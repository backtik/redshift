# # Singleton object to represent the browser, normalized for browser differences
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
  
  def Engine.presto?
    Engine[:name] == 'presto'
  end
  
  def Engine.trident?
    Engine[:name] == 'trident'
  end
  
  def Engine.webkit?
    Engine[:name] == 'trident'
  end
  
  def Engine.gecko?
    Engine[:name] == 'gecko'
  end
end