require 'code_events'

# Class +Transform+ provides the ability for transition from a starting number value to a final number value
# by stepping through a series of sequential transformations using a transition algorithm. 
class Transform
  include CodeEvents
  OPTIONS = {:fps => 50,
	           :unit => false,
	           :duration => 500,
	           :link => 'ignore'
	          }
	
	DURATIONS = {:short => 250, 
	             :normal => 500,
	             :long => 1000
	            }
	
	
	# at the end of an interval based transformation clears the Timeout and Intervals
	# in the browser and returns nil.
	`$clear = function(timer){clearTimeout(timer);clearInterval(timer);return nil;};`
	
	# need periodical for setInterval on Effect#step. 
	`Function.prototype.create = function(options){
		var self = this;
		options = options || {};
		return function(event){
			var args = options.arguments;
			args = (args != undefined) ? $splat(args) : Array.slice(arguments, (options.event) ? 1 : 0);
			if (options.event) args = [event || window.event].extend(args);
			var returns = function(){
				return self.apply(options.bind || null, args);
			};
			if (options.delay) return setTimeout(returns, options.delay);
			if (options.periodical) return setInterval(returns, options.periodical);
			return returns();
		};
	}`
	`Function.prototype.periodical = function(periodical, bind, args){
		return this.create({bind: bind, arguments: args, periodical: periodical})();
	};`
	
	def self.compute(from, to, delta)
  	`(to - from) * delta + from`
  end
	
	def initialize(options={})
	  @subject = @subject || self
		@options = OPTIONS.merge(options)
		@options[:duration] = Transform::DURATIONS[@options[:duration]] || @options[:duration].to_i
		wait = @options[:wait]
		@options[:link] = 'cancel' if wait === false
	end

	def step
	  `
    var time = +new Date
		if (time < this.__time__ + #{@options[:duration]}){
			var delta = this.__transition__((time - this.__time__) / #{@options[:duration]});
			this.m$set(this.m$compute(this.__from__, this.__to__, delta));
		} else {
			this.m$set(this.m$compute(this.__from__, this.__to__, 1));
			this.m$complete();
		}
		`
	  return nil
	end
	
	def set(now)
	  return now
	end
	
	def compute(from, to, delta)
    return Transform.compute(from, to, delta) 
	end
	
	def check(caller)
	  `
    if (!this.__timer__) return true;
		switch (#{@options[:link]}){
			case 'cancel': this.cancel(); return true;
			case 'chain' : this.chain(caller.bind(this, Array.slice(arguments, 1))); return false;
		}`
		return false
	end
	
	def start(from,to)
    `if (!this.m$check(arguments.callee, from, to)) return this`
		`this.__from__ = from`
		`this.__to__   = to`
		`this.__time__ = 0`
		`this.__transition__ = function(p){
			return -(Math.cos(Math.PI * p) - 1) / 2;
		}`
    self.start_timer
		self.fire(:start)
		return self
	end
		
	def complete
	 self.fire(:completion)
	 self.stop_timer
	 self
	end
	
	def cancel
	 self.fire(:cancellation)
	 self.stop_timer
 	 self
	end
	
	def pause
	  self.stop_timer
	  self
	end
	
	def resume
	 self.start_timer
	 self
	end
	
	def stop_timer
		`if (!this.__timer__) return false`
		`this.__time__ = (+new Date) - this.__time__`
		`this.__timer__ = $clear(this.__timer__)`
		return true
	end
	
	def start_timer
    `if (this.__timer__) return false`
		`this.__time__ = (+new Date) - this.__time__`
    `this.__timer__ = this.m$step.periodical(Math.round(1000 / #{@options[:fps]}), this)`
		return true
	end
  

  # Module +Parser+ is responsible for turning a value into a computable value (integer or array of integers),
  # computing this value to the correct 
  module Parser
    
    # Class Color is responsible for handling css color values in either hex (#fff) or rgb triplet (rgb(0,0,0))
    # formats by parsing them to an array of numbers, transforming each elemement in the array during a transition
    # and finally serving the then number at the end of a series of transforms.
    class Color
      def self.hex_to_array(color)
        `var hex = color.match(/^#?(\\w{1,2})(\\w{1,2})(\\w{1,2})$/).slice(1)`
        `var rgb = []
    		for(i = 0, l = hex.length; i < hex.length; i++){
    		  value = hex[i]
    		  if (value.length == 1) value += value;
    		  rgb[i] = parseInt(value,16);
    		}`
    		`rgb`
      end
      
      # call-seq:
      #   Parser::Color.compute(array,array,float) -> string
      # 
      # Computes from an array of current values to an array of new values
      # based on a delta by computing each value in the array.
      # returns a css-compatible rgb triplet string (rgb(00,00,00))
      # 
      # In a sequence of steps converting from rgb(0,0,0) to rgb(240,240,240)
      # Parser::Color.compute may be called with
      # Parser::Color.compute([0,0,0], [240,240,240], 0.8272711231312) and will
      # return 'rbg(199,199,199)'
      def self.compute(from, to, delta)
  			rgb = []
  			from.each do |i|
  			  rgb << `Math.round(#{::Transform.compute(from[i], to[i], delta)})`
			  end
        `'rgb(' + rgb + ')'`
      end
      
      # call-seq:
      #   Parser::Color.parse(str) -> array or false
      # Parses a css color value from either hex (#f0f0f0) or rgb triplet (rbg(240,240,240)) to an array
      # of rgb values or returns false if the value cannot be parsed 
      #
      # Parser::Color.parse('#fff')   # => [255,255,255]
      # Parser::Color.parse('f0f0f0') # => [240,240,240]
      # Parser::Color.parse('rbg(240,240,240)) # => [240,240,240]
      #  
      # Parser::Color.parse('40px')   # => false
      # Parser::Color.parse('left')   # => false
      def self.parse(value) # :nodoc
        `value = value.__value__ || String(value)`
        `if (value.match(/^#[0-9a-f]{3,6}$/i)) return #{Transform::Parser::Color.hex_to_array(value)}`
  			`((value = value.match(/(\\d+),\\s*(\\d+),\\s*(\\d+)/))) ? #{[value[1], value[2], value[3]]} : false`
      end
      
      # Returns the final value in rgb triplet format at the termination of a series of transformations
      # The second argument (unit) exists for polymorphic calls and is not used.
      def self.serve(value, unit)
        value
      end
    end
    
    # Class Color is responsible for handling css numbers values with our without units
    # parsing them, computing new values, and returning a final value with its intial unit reapplied.
    class Number
      # call-seq:
      #   Parser::Number.compute(number,number,float) -> string
      # 
      # Computes from an current value to a newvalue 
      # based on a delta and returns a css compatible string.
      # 
      def self.compute(from,to,delta)
        Transform.compute(from,to,delta)
      end
      
      # call-seq:
      #   Parser::Number.parse(str or number) -> number or false
      # Parses a number value from as either a string or number and returns an integer
      # that will later be transformed.
      # Returns false if the value cannot be parsed as a number
      #
      # Parser::Number.parse(20)   # => 20
      # Parser::Number.parse(0)    # => 0
      # Parser::Number.parse('220px')    # => 220
      #  
      # Parser::Number.parse('left')   # => false
      def self.parse(value)
        `value = value.__value__ || String(value)`
        `parsed = parseFloat(value)`
        `(parsed || parsed == 0) ? parsed : false`
      end
      
      # Returns the final value as a string at the termination of a series of transformations
      # with its inital unit reapplied
      # 
      # Parser::Number.serve(20,'px') # => '20px'
      # Parser::Number.serve(40, nil) # => '40
      # The second argument (unit) exists for polymorphic calls and is not used.
      def self.serve(value, unit)
        return (unit) ? value + unit : value
      end
    end
    
    # Class String is responsible for handling css string values which cannot be parsed. Simple transforms
    # from a start value to end value with no transform.
    class String
      def self.parse(value)
        false
      end
      
      def self.compute(from, to, delta)
        return to        
      end
      
      def self.serve(value, unit)
        return value
      end
    end
  end
  
  Parsers = [Parser::Color, Parser::Number, Parser::String]
end