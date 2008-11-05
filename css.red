require 'transform'

module CSS
  module Parser
    class Color
      def self.hex_to_rgb(color)
        `var hex = color.match(/^#?(\\w{1,2})(\\w{1,2})(\\w{1,2})$/)`
    		`(hex) ? this.m$hex_array_to_rgb(hex.slice(1)) : nil`
      end
      
      def self.hex_array_to_rgb(array)
        `
        if (array.length != 3) return nil;
    		var rgb = []
    		for(i = 0, l = array.length; i < array.length; i++){
    		  value = array[i]
    		  if (value.length == 1) value += value;
    		  rgb[i] = parseInt(value,16);
    		}`
    		`rgb`
      end

      def self.compute(from, to, delta)
  			rgb = []
  			from.each do |i|
  			  rgb << `Math.round(#{Transform.compute(from[i], to[i], delta)})`
			  end
        `'rgb(' + rgb + ')'`
      end
      
      def self.parse(value)
        `value = value.__value__ || String(value)`
        `if (value.match(/^#[0-9a-f]{3,6}$/i)) return #{CSS::Parser::Color.hex_to_rgb(value)}`
  			`((value = value.match(/(\\d+),\\s*(\\d+),\\s*(\\d+)/))) ? #{[value[1], value[2], value[3]]} : false`
      end
      
      def self.serve(value, unit)
        value
      end
    end
    
    class Number
      def self.compute(from,to,delta)
        ::Transform.compute(from,to,delta)
      end
      
      def self.parse(value)
        `value = value.__value__ || String(value)`
        `parsed = parseFloat(value)`
        `(parsed || parsed == 0) ? parsed : false`
      end
      
      def self.serve(value, unit)
        return (unit) ? value + unit : value
      end
    end
    
    # can't tween a string
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