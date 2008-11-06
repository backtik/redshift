class Element
  # knows element valid attributes & element valid styles
  # if you try to set or get invalid attribute or style, warns A
  # if you try to set an invalid value to an attribute or style, warns B
  module Validator
    # attributes shared by all elements; checked last
    ATTRIBUTES = {
      :class => lambda {|klass| true }
      :id    => lambda {|id|    true }
      :style => lambda {|style| true }
      :title => lambda {|title| true }
    }
    
    class A
      ATTRIBUTES = {
        :href => lambda {|href| true }
        :rel  => lambda {|href| true }
      }
    end
  end
end