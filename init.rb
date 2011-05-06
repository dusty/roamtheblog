# Bundler
require "rubygems"
require "bundler/setup"

# Include required gems
%w{
  mongomatic rack-flash sinatra/base RedCloth mustache/sinatra chronic tzinfo
  html_truncator
}.each {|req| require req }

# Require custom libraries
Dir["lib/**/*.rb"].sort.each {|req| require req}

## Setup mongomatic database
Mongomatic.db = Mongo::Connection.new(ENV['MONGO_HOST'],ENV['MONGO_PORT']).db(ENV['MONGO_DB'])
if (ENV['MONGO_USER'] && ENV['MONGO_PASS'])
  Mongomatic.db.authenticate(ENV['MONGO_USER'], ENV['MONGO_PASS'])
end

# Require sinatra apps
Dir["apps/**/*.rb"].sort.each {|req| require req}

# Require mustache views
Dir["views/**/*.rb"].sort.each {|req| require req}

# Create defaults
User.create_default
Site.create_default