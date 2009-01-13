require 'herring'

Rack::Herring::HerringRoot = File.dirname(__FILE__)
BANNER = <<END
  ********* Loaded **********
  Running Red v#{Red::VERSION} on Red Herring v#{Herring::VERSION} in debug mode.
  ***************************
END
use Rack::ShowExceptions
run Rack::Herring.new
puts BANNER
