require 'javascripts/browser.red'
require 'javascripts/document.red'
require 'javascripts/chainable.red'
require 'javascripts/cookie.red'
require 'javascripts/request.red'

Document.ready? do
  class Foo
    include Chainable
  end
  
  foo = Foo.new
  foo.chain {|x,y,z| x * (y + z) }
  
  puts foo.call_chain(4,5,6)
  puts foo.call_chain
end
