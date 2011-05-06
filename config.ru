$: << File.join(File.dirname(__FILE__))
require 'init'

run Rack::URLMap.new(
  '/'      => Roam::User.new,
  '/admin' => Roam::Admin.new
)