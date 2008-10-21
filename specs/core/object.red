Spec.describe Object do |it|
  it.can 'find its class'
  
  it.can 'be extended with additioanl functionality' do
    module Stuff
      def x
      end
    end
    
    o = Object.new
    o.extend(Stuff)
    o.respond_to?(:x).should_be_true
  end
  
  it.has 'an object_id' do
    Object.new.object_id.should_not_be_nil
  end
  
  it.can 'tell whether it will respond to a method referenced as a symbol' do
    Object.respond_to?(:respond_to?).should_be_true
  end
end