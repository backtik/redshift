class Request
  OPTIONS = {
    :url => '',
		:data => '',
		:headers=>  {
			'X-Requested-With' => 'XMLHttpRequest',
			'Accept' =>  'text/javascript, text/html, application/xml, text/xml, */*'
		},
		:async => true,
		:format => false,
		:method => 'GET',
		:link => 'ignore',
		:isSuccess => nil,
		:emulation => true,
		:urlEncoded => true,
		:encoding => 'utf-8',
		:evalScripts => false,
		:evalResponse => false
  }
  
  attr :on_state_change
  
  def initialize(options)
    @xhr = Browser::Request
    @options = OPTIONS.merge(options)
    @on_state_change = lambda {
      return unless `#{@xhr}.readyState == 4 || #{@running}`
          
      @running = false
      @status  = 0
      
      begin
        @status = `#{@xhr}.status`
      rescue 
        return nil
      end
        
      if self.success?
        self.success!(`#{@xhr}.responseText`, `#{@xhr}.responseXML`)
      else
        @response = {:text => nil, :xml => nil};
  			self.fail!
      end
    
      `#{@xhr}.onreadystatechange` = nil
    }
  end
  
  def headers
    @options[:headers]
  end
  
	def success?
		@status >= 200 && @status < 300
	end
	
	def success!
	  self.fire_event('complete').fire_event('success')
  end
  
  def process_scripts
    
  end
  
  def fail!
    self.fire_event('complete').fire_event('failure', @xhr);
  end
  
  def set_header(k,v)
    
  end
  
  def get_header
    
  end
  
  def check
    return true unless @running
    case @options[:link]
    when 'cancel'
       self.cancel
       return true
    when 'chain'  : return false
    else
      return false
    end
  end
  
  def execute(options)
    return self unless self.check
    @running = true
    
    
    if @options[:format]
      format = 'format=' + @options[:format]
			data = (data ? (format + '&' + data) : format)
    end
    
    # use rails style emulation of put and delete requests
    if @options[:emulation] && ['put', 'delete'].contains(method)
      _method = '_method=' + method
    	data = data ? _method + '&' + data : _method
    	method = 'post'
    end
    
    # use special encoding if neccessary
    if @options[:urlEncoded] && method == 'post'
			encoding = @options[:encoding] ? '; charset=' + @options[:encoding] : ''
			self.headers['Content-type'] = 'application/x-www-form-urlencoded' + encoding
		end
    
    # if there is data and the method is get, add the data as query parameters
    # to the request
    if data && method == 'get'
			url = url + (url.contains('?') ? '&' : '?') + data
			data = nil
		end
    
    # use the browser's built-in XHR abiliy to open a new request
    `#{@xhr}.open#{(@options[:method]}, #{@options[:url]}, #{@options[:async]})`
    
    `#{@xhr}.onreadystatechange` = self.on_state_change
    
    # use the brower's built-in XHR ability to send the data
    `#{@xhr}.send(data)`

    self.on_state_change unless @options[:async]
		return self
  end
  
  def cancel
    return self unless @running
    @running = false
    @xhr.abort
    `#{@xhr}.onreadystatechange` = nil
    @xhr = Browser::Request
    self.fire_event('cancel')
    return self
  end  
end