require 'code_events'

class Transform
  include CodeEvents
  OPTIONS = {:fps => 50,
	           :unit => false,
	           :duration => 500,
	           :link => 'ignore'
	          }
	
	Durations = {:short => 250, 
	             :normal => 500,
	             :long => 1000
	            }
		
	`$clear = function(timer){clearTimeout(timer);clearInterval(timer);return nil;};`
	
	# need periodical fot setInterval on Effect#step. Find out what
	# setInterval is when there is net again.
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
		@options[:duration] = Transform::Durations[@options[:duration]] || @options[:duration].to_i
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
end