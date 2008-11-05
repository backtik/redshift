require '../redshift.red'

Document.ready? do
  class Looper
    include CodeEvents
    
    def initialize(range)
      @range = range
    end
    
    def run(min, max)
      self.fire(:start)
      @range.each do |i|
        self.fire(:minimum, 0, i) && next if i == min
        self.fire(:maximum, 0, i) && next if i == max
        puts i
      end
      return self
    end
  end
  
  looper = Looper.new([1,2,3,4,5,6,7,8,9,10])
  
  looper.upon :start do puts "The loop has begun" end          
  p_min = Proc.new {|i| puts "Minimum amount reached: %s" % i }
  p_max = Proc.new {|i| puts "Maximum amount reached: %s" % i }
  looper.upon(:minimum => p_min, :maximum => p_max)            
  
  looper.run(3,8)
end