require 'javascripts/redshift.red'

class Foo
  def name
    "worked"
  end
  
  def procout
    proc { |element| puts element.name }
  end
end

Document.ready? do
  foo = Foo.new
  foo.procout.call(foo)
end
