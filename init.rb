# Bundler
require "rubygems"
require "bundler/setup"

# Include required gems
%w{
  mongo_mapper rack-flash sinatra/base mustache/sinatra RedCloth chronic html_truncator tzinfo
}.each {|req| require req }

# Require custom libraries
Dir["lib/**/*.rb"].sort.each {|req| require req}

## Connect to MongoDB
MongoMapper.connection = Mongo::Connection.new(ENV['MONGO_HOST'],ENV['MONGO_PORT'])
MongoMapper.database = ENV['MONGO_DB'] || 'roamtheblog'
if (ENV['MONGO_USER'] && ENV['MONGO_PASS'])
  MongoMapper.database.authenticate(ENV['MONGO_USER'], ENV['MONGO_PASS'])
end

# Require sinatra apps
Dir["models/*.rb"].sort.each {|req| require req}
Dir["app/*.rb"].sort.each {|req| require req}

# Require mustache views
Dir["views/**/*.rb"].sort.each {|req| require req}

# Create defaults
User.create_default
Site.create_default