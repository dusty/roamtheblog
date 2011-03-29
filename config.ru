$: << File.join(File.dirname(__FILE__))
require 'init'

run Rack::URLMap.new(
  '/'      => UserApp.new,
  '/admin' => AdminApp.new
)