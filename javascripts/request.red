class Request
  # include Event
  
  METHODS = %w(GET POST PUT DELETE)
  OPTIONS = {
    :url           => '',
    :data          => {},
    :link          => 'ignore',
    :async         => true,
    :format        => nil,
    :method        => 'post',
    :encoding      => 'utf-8',
    :is_success    => nil,
    :emulation     => true,
    :url_encoded   => true,
    :eval_scripts  => false,
    :eval_response => false,
    :headers       => {
      'X-Requested-With' => 'XMLHttpRequest',
      'Accept'           => 'text/javascript, text/html, application/xml, text/xml, */*'
    }
  }
  
  # call-seq:
  #   Request.new(options = {}) -> request
  # 
  # Returns a new _request_ with the given options.
  # 
  def initialize(options = {})
    @xhr = `typeof(ActiveXObject)=='undefined' ? new XMLHttpRequest : new ActiveXObject('MSXML2.XMLHTTP')`
    @options = OPTIONS.merge(options)
    `#{@options[:headers]}.__xhr__=#{@xhr}`  # MooTools sets the ResponseHeaders in the xhr
    def (@options[:headers]).[](name)        # only during execution, but allows you to get
      `this.__xhr__.getResponseHeader(name)` # at them at any time. I'm not sure whether it
    end                                      # is necessary for us to emulate this exactly.
  end
  
  # call-seq:
  #   req.cancel -> req
  # 
  # Cancels the request, fires its "cancel" event, and returns _req_.
  # 
  def cancel
    return self unless @running
    @running = false
    `#{@xhr}.abort`
    `#{@xhr}.onreadystatechange=function(){;}`
    @xhr = `typeof(ActiveXObject)=='undefined' ? new XMLHttpRequest : new ActiveXObject('MSXML2.XMLHTTP')`
    self.fire_event('cancel')
    return self
  end
  
  # call-seq:
  #   req.check(arg, ...) { |request,args_array| block } -> true or false
  # 
  # returns +true+ when Request object is not running or gets cancelled, otherwise returns false.
  # also, seems equipped to 'chain' some additional function after itself
  # 
  def check(*args, &block)
    return true unless @running
    case @options[:link]
    when 'cancel'
      self.cancel
      return true
    when 'chain'
      # self.chain(&block(self,args))
      return false
    end
    return false
  end
  
  # call-seq:
  #   req.execute(options = {}) -> req
  # 
  # Returns +req+ immediately if the request is already running. Otherwise,
  # opens a connection and sends the data provided with the specified options.
  # 
  def execute(options = {})
    # return self unless self.check(options)
    @options.update(options)
    raise(TypeError, 'can\'t convert %s to a String' % @options[:url].inspect) unless [String].include?(@options[:url].class)
    raise(TypeError, 'can\'t convert %s to a String' % @options[:method].inspect) unless [String, Symbol].include?(@options[:method].class)
    raise(TypeError, 'can\'t convert %s to a Hash' % @options[:data].inspect) unless [Hash].include?(@options[:data].class)
    raise(HttpMethodError, 'invalid HTTP method "%s" for %s' % [@options[:method],self]) unless METHODS.include?(method = @options[:method].to_s.upcase)
    
    @running = true
    data = @options[:data].to_query_string
    url = @options[:url]
    
    if @options[:format]
      format = "format=%s" % @options[:format]
      data   = data.empty? ? format : [format, data].join('&')
    end
    
    if @options[:emulation] && %w(PUT DELETE).include?(method)
      _method = "_method=%s" % method
      data    = data.empty? ? _method : [_method, data].join('&')
      method  = 'POST'
    end
    
    if @options[:url_encoded] && method == 'POST'
      encoding = @options[:encoding] ? "; charset=%s" % @options[:encoding] : ""
      self.headers['Content-type'] = "application/x-www-form-urlencoded" + encoding
    end
    
    if data && method == 'GET'
      separator = url.include?('?') ? "&" : "?"
      url       = [url, data].join(separator)
      data      = nil
    end
    
    `#{@xhr}.open(#{method}.__value__, #{url}.__value__, #{@options[:async]})`
    `#{@xhr}.onreadystatechange = #{self.on_state_change}.__block__`
    
    @options[:headers].each do |k,v|
      `#{@xhr}.setRequestHeader(k.__value__,v.__value__)`
    # raise(HeaderError, "#{k} => #{v}")
    end
    
    self.fire_event('request')
    `#{@xhr}.send($T(data)?data.__value__:'')`
    self.on_state_change.call unless @options[:async]
    return self
  end
  
  # call-seq:
  #   req.failure! -> req
  # 
  # Fires _req_'s "complete" and "failure" events, then returns _req_.
  # 
  def failure!
    self.fire_event('complete').fire_event('failure', @xhr);
  end
  
  # call-seq:
  #   req.headers -> hash
  # 
  # Returns _req_'s HTTP headers as a +Hash+.
  # 
  def headers
    @options[:headers]
  end
  
  # call-seq:
  #   req.on_state_chang -> proc
  # 
  # Returns a +Proc+ object
  # 
  def on_state_change
    proc do
      `if(#{@xhr}.readyState!=4||!#{@running}){return nil;}`
      
      @running = false
      @status  = 0
      
      `try{#{@status}=#{@xhr}.status}catch(e){;}`
      
      if self.success?
        @response = {:text => `$q(#{@xhr}.responseText)`, :xml => `#{@xhr}.responseXML`}
        self.success!(self.process_scripts(@response[:text]), @response[:xml])
      else
        @response = {:text => nil, :xml => nil};
        self.failure!
      end
      
      `#{@xhr}.onreadystatechange=function(){;}`
      
      return nil
    end
  end
  
  # call-seq:
  #   req.process_scripts(str) -> string or object
  # 
  # If the HTTP response consists of JavaScript alone or if _req_'s
  # <tt>eval_response</tt> option is set to +true+, evaluates the entire
  # text of the response as JavaScript and returns the result.
  # 
  # Otherwise, returns a copy of _str_ with any <tt><script></tt> tags and
  # their content removed. If _req_'s <tt>eval_scripts</tt> option is set to
  # +true+, evaluates the removed scripts.
  # 
  def process_scripts(str)
    return Document.execute_js(str) if @options[:eval_response] || `/(ecma|java)script/.test(this.i$xhr.getResponseHeader('Content-Type'))`
    return str.strip_scripts(@options[:eval_scripts])
  end
  
  # call-seq:
  #   req.success!(text, xml) -> req
  # 
  # Fires _req_'s "complete" and "success" events, then returns _req_.
  # 
  def success!(text, xml)
    self.fire_event('complete', [text, xml]).fire_event('success', [text, xml])
  end
  
  # call-seq:
  #   req.success? -> true or false
  # 
  # Returns +true+ if _req_'s status is in the 200s, +false+ otherwise.
  # 
  def success?
    `#{@status}>=200&&#{@status}<300`
  end
  
  # This is a stub
  def fire_event # :nodoc:
    return self
  end
  
  # +HeaderError+ is raised when a +Request+ is executed with headers that are
  # rejected by the XMLHTTPRequest object.
  # 
  class HeaderError < StandardError
  end
  
  # +HttpMethodError+ is raised when a +Request+ object's HTTP method is not
  # one of +GET+, +POST+, +PUT+, or +DELETE+.
  # 
  class HttpMethodError < StandardError
  end
  
  class ::String
    # call-seq:
    #   str.strip_scripts(evaluate = false) -> string
    # 
    # Returns a copy of _str_ with the contents of any <tt><script></tt> tags
    # removed. If _evaluate_ is set to true, the stripped scripts will be
    # evaluated.
    # 
    def strip_scripts(evaluate = false)
      scripts = ''
      result = `this.__value__.replace(/<script[^>]*>([\\s\\S]*?)<\\/script>/gi,function(){scripts.__value__+=arguments[1]+'\\n';return '';})`
      Document.execute_js(scripts) if evaluate
      return result
    end
  end
  
  class ::Hash
    # call-seq:
    #   hsh.to_query_string -> string
    # 
    # Returns a string representing _hsh_ formatted as HTTP data.
    # 
    def to_query_string(base = '')
      query_string = []
      self.each do |k,v|
        next if v.nil?
        k = base.empty? ? k.to_s : "%s[%s]" % [base,k]
        case v
        when Hash
          result = v.to_query_string(k)
        when Array
          qs = {}
          `for(var i=0,l=v.length;i<l;i++){#{qs[i] = v[i]}}`
          #v.each_with_index do |v,i|
          #  qs[i] = v
          #end
          result = qs.to_query_string(k)
        else
          result = "%s=%s" % [k, `$q(encodeURIComponent(v))`]
        end
        query_string.push(result)
      end
      return query_string.join('&')
    end
  end
  
  class HTML
  end
  
  class JSON
  end
end
