require 'document'

# Class +Cookie+ governs the writing and accessing of cookies in the browser.
# 
# A cookie is a key-value pair stored by your browser as text data. If you
# know a cookie's key, you can read or overwrite its value, or reassign any of
# a number of parameters.
# 
# Instances of class +Cookie+ are temporary holders for browser-based cookie
# data. When you create a new +Cookie+ object using <tt>Cookie.new</tt> or
# update an existing +Cookie+ object using <tt>Cookie#update</tt>, class
# +Cookie+ writes the key-value pair and the cookie's parameters to the
# browser's cookie file. You can then read the value of the cookie immediately
# or during subsequent visits using <tt>Cookie.read</tt>.
# 
# The following parameters can be set for a +Cookie+ object:
# 
# *Required*
# _key_::   The unique (per domain) identifier by which you identify a cookie.
# _value_:: The string of data associated with a given key.
# 
# *Optional*
# _duration_:: The amount of time (in days) before the cookie should expire.
# _domain_::   The domain to which the cookie should be sent.
# _path_::     The path, relative to the domain, where the cookie is active.
# _secure_::   If +true+, the browser will use SSL when sending the cookie.
# 
# The browser can hold up to 20 cookies from a single domain.
# 
class Cookie
  OPTIONS = {
    :duration => nil,
    :domain   => nil,
    :path     => nil,
    :secure   => false,
    :document => Document
  }
  
  attr_accessor :key, :value, :duration, :domain, :path, :secure, :document
  
  # call-seq:
  #   Cookie.new(key, value, options = {}) -> cookie
  # 
  # Returns a new +Cookie+ object with the given parameters and stores the
  # data in the browser as cookie data. If the browser already has a cookie
  # that matches _key_, that cookie's parameters will be overwritten.
  # 
  #   Cookie.new(:user_jds, '2237115568')   #=> #<Cookie: @key="user_jds" @value="2237115568">
  #   Cookie.read(:user_jds)                #=> '2237115568'
  #   
  #   Cookie.new(:user_jds, '8557acb0')     #=> #<Cookie: @key="user_jds" @value="8557acb0">
  #   Cookie.read(:user_jds)                #=> '8557acb0'
  # 
  def initialize(key, value, options = {})
    self.key = key
    self.update(value, OPTIONS.merge(options))
  end
  
  # call-seq:
  #   Cookie.read(key) -> string
  # 
  # Returns the string value of the cookie named _key_, or +nil+ if no such
  # cookie exists.
  # 
  #   c = Cookie.new(:user_jds, '2237115568', :domain => '.example.com')
  #   
  #   Cookie.read(:user_jds)   #=> '2237115568'
  # 
  # This method can be used to test whether a cookie with the name _key_
  # exists in the browser.
  # 
  #   Cookie.new(:user_jds, '8557acb0') unless Cookie.read(:user_jds)
  # 
  def self.read(key)
    value = `#{OPTIONS[:document]}.__native__.cookie.match('(?:^|;)\\s*' + #{Regexp.escape(key)}.__value__ + '=([^;]*)')`
    return value ? `$q(decodeURIComponent(value[1]))` : nil
  end
  
  # call-seq:
  #   Cookie.store(cookie) -> cookie
  # 
  # Writes the given cookie to the browser, then returns _cookie_. This method
  # is called internally by <tt>Cookie.new</tt> and <tt>Cookie#update</tt>.
  # 
  def self.store(cookie)
    `var str = cookie.m$key().__value__ + '=' + encodeURIComponent(cookie.m$value().__value__)`
    `str += '; domain=' + cookie.m$domain().__value__` if cookie.domain
    `str += '; path='   + cookie.m$path().__value__`   if cookie.path
    if cookie.duration
      `date = new Date()`
      `date.setTime(date.getTime() + cookie.m$duration() * 86400000)`
      `str += '; expires=' + date.toGMTString()`
    end
    `str += '; secure'` if cookie.secure
    
    `#{cookie.document}.__native__.cookie = str`
    return cookie
  end
  
  # call-seq:
  #   cookie.destroy -> true
  # 
  # Expires _cookie_, then returns +true+.
  # 
  #   c = Cookie.new(:user_jds, '2237115568', :duration => 14)
  #   
  #   c.destroy                 #=> true
  #   Cookie.read(:user_jds)    #=> nil
  # 
  def destroy
    self.update('',:duration => -1)
  end
  
  # call-seq:
  #   cookie.inspect -> string
  # 
  # Returns a string representing _cookie_ and its key-value data.
  # 
  #   c = Cookie.new(:user_jds, '2237115568', :duration => 14)
  #   
  #   c.inspect   #=> #<Cookie: @key="user_jds" @value="2237115568">
  # 
  def inspect
    "#<Cookie: @key=#{self.key.inspect} @value=#{self.value.inspect}>"
  end
  
  # call-seq:
  #   cookie.update(value, options = {}) -> cookie
  # 
  # Updates _cookie_ with the given parameters, then writes the cookie data to
  # the browser.
  # 
  #   c = Cookie.new(:user_jds, '2237115568', :duration => 14)
  #   
  #   Cookie.read(:user_jds)    #=> '2237115568'
  #   c.update('8557acb0')      #=> #<Cookie: @key="user_jds" @value="8557acb0">
  #   Cookie.read(:user_jds)    #=> '8557acb0'
  # 
  def update(value, options = {})
    self.value = value
    options.each {|k,v| self.send("#{k}=",v) }
    Cookie.store(self)
  end
end
