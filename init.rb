# Bundler
require "rubygems"
require "bundler/setup"

# Include required gems
%w{ 
  mongomatic rack-flash sinatra/base RedCloth mustache/sinatra chronic tzinfo
  html_truncator
}.each {|req| require req }

# Init mongo connection
Mongomatic.db = Mongo::Connection.new(
  ENV['MONGO_HOST'] || 'localhost',
  ENV['MONGO_PORT'] || 27017
).db(ENV['MONGO_DB'] || 'roamtheblog')

# Authenticate if needed
if (ENV['MONGO_USER'] && ENV['MONGO_PASS'])
  Mongomatic.db.authenticate(ENV['MONGO_USER'], ENV['MONGO_PASS'])
end

# Require custom libraries
Dir["lib/**/*.rb"].sort.each {|req| require req}

# Create defaults
User.create_default
Site.create_default 
Design.create_default

# Require apps
Dir["apps/**/*.rb"].sort.each {|req| require req}

