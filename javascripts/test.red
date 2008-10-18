class Foo
end

class String
  def js
    `#{self}._value`
  end
end

f = Foo.new
puts f.object_id.to_s.js