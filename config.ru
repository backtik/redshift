$:.unshift(File.join(File.dirname(__FILE__), '/lib'))
require 'herring_rack'

use Rack::ShowExceptions
run Rack::Herring.new
