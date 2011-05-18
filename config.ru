$: << File.join(File.dirname(__FILE__))
require 'init'

run Rack::URLMap.new(
  '/'      => Roam::UserApp.new,
  '/admin' => Roam::AdminApp.new
)