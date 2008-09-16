require 'herring_rack'

use Rack::ShowExceptions
run Rack::Herring.new
