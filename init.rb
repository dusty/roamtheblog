# Bundler
require "rubygems"
require "bundler/setup"

# Include required gems
%w{
  mongo_mapper rack-flash sinatra/base mustache/sinatra RedCloth chronic html_truncator tzinfo
  active_support/inflector
}.each {|req| require req }

# Require custom libraries
Dir["./lib/**/*.rb"].sort.each {|req| require req}

## Connect to MongoDB
MongoMapper.connection = Mongo::Connection.new(ENV['MONGO_HOST'],ENV['MONGO_PORT'])
MongoMapper.database = ENV['MONGO_DB'] || 'roamtheblog'
if (ENV['MONGO_USER'] && ENV['MONGO_PASS'])
  MongoMapper.database.authenticate(ENV['MONGO_USER'], ENV['MONGO_PASS'])
end

## Setup Email options
SMTP_OPTS = {
  :address => ENV['SMTP_HOST'],
  :user_name => ENV['SMTP_USER'],
  :password => ENV['SMTP_PASS'],
  :port => ENV['SMTP_PORT'],
  :authentication => ENV['SMTP_AUTH'],
  :domain => ENV['SMTP_DOMAIN'] || 'localhost.localdomain'
}

# Require sinatra apps
Dir["./models/*.rb"].sort.each {|req| require req}
Dir["./app/*.rb"].sort.each {|req| require req}

# Require mustache views
Dir["./views/**/*.rb"].sort.each {|req| require req}

# Create defaults
User.create_default
Site.create_default
