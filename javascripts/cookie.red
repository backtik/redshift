class Cookie
  OPTIONS = {:path => false, :domain => false, :duration => false, :secure => false, :document => ::Doc}
  
  def initialize(key, options = {})
    @key = key
    @options = options.merge(OPTIONS)
  end
  
  def write(value)
    value = `encodeURIComponent(value)`
		value += '; domain=' + @options[:domain] if (@options[:domain]) 
		value += '; path=' + @options[:path] if (@options[:path])
		if @options[:duration]
			`date = new Date()`
			`date.setTime(date.getTime() + this.options.duration * 24 * 60 * 60 * 1000)`
			 value += '; expires=' + `date.toGMTString()`
		end
		
		value += '; secure' if (@options[:secure]) 
		`#{@options[:document].native}.cookie = #{@key} + '=' + value`
		return self
  end
  
  def read
    value = `#{@options[:document].native}.cookie.match('(?:^|;)\\s*' + #{@key}.toString().escapeRegExp() + '=([^;]*)')`
		return value ? `decodeURIComponent(value[1])` : nil
  end
  
  def destroy
    Cookie.new(@key, @options.merge({:duration => -1})).write('')
		return self
  end
end