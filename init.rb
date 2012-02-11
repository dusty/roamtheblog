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
uri = URI.parse(ENV['MONGOLAB_URI'] || 'mongodb://localhost/roamtheblog')
db  = uri.path.gsub(/^\//,'')
MongoMapper.connection = Mongo::Connection.from_uri(uri.to_s)
MongoMapper.database = db

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

# Create defaults
User.create_default
Site.create_default
