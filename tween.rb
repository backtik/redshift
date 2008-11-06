require 'transform'

class Tween < Transform
  def initialize(element, options)
    @element = @subject = element
    super(options)
  end
  
  def start(property, from, to)
    @property = property
    parsed = self.prepare(@element, property, [from, to])
    super(parsed[:from], parsed[:to])
  end
  
  def prepare(element, property, from_to)
    to = from_to[1]
    # set a default to, if one isn't set
    if (!to)
      from_to[1] = from_to[0]
      from_to[0] = element.styles[property]
    end
    # convert from and to to numeric values from hex/string if possible
    parsed_from_to = []
      from_to.each do |val|
        parsed_from_to << self.parse(val)
      end
    return {:from => parsed_from_to[0], :to => parsed_from_to[1]}
  end
  
  # parses a value by its Parser, returning a hash of the parsed value and parser
  def parse(value)
    value = value.to_s.split(' ')
    returns = []
    value.each do |val|
      ::Transform::Parsers.each do |parser|
       parsed = parser.parse(val)
       `console.log(parsed)`
       found = {:value => parsed, :parser => parser}  if (parsed)
      end
      found = found || {:value => val, :parser => ::Transform::Parser::String}
      returns << found
    end
    return returns
  end
  
  def set(current_value)
    self.render(@element, @property, current_value[0], @options[:unit])
		return self
  end
  
  def render(element, property, current_value, unit)
    element.set_style(property, self.serve(current_value, unit))
  end
  
  def serve(value, unit)
    value[:parser].serve(value[:value], unit)
  end
  
  def compute(from,to,delta)
    computed = []
    (`Math.min(from.length, to.length)`).times do |i|
     computed << {:value => from[i][:parser].compute(from[i][:value], to[i][:value], delta), :parser => from[i][:parser]}
    end
    return computed 
  end
end