require 'javascripts/redshift.red'

Document.ready? do
  req = Request.new(:url => 'http://localhost:9292/html/requests.html', :method => 'get')
  req.upon(:success) { puts "it worked" }
  req.upon(:failure) { puts "it failed" }
  req.upon(:request) { puts "sending..." }
  req.upon(:response) { puts "received" }
  Document['#blue'].listen :mouse_wheel do
    req.execute
  end
end
