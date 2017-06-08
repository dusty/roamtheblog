require './app'

run Rack::URLMap.new(
  '/'      => Roam::UserApp.new,
  '/admin' => Roam::AdminApp.new
)
