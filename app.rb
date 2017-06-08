# Load env
require 'dotenv'
Dotenv.load

# Bundler
require "rubygems"
require "bundler/setup"

# Include required gems
%w{
  mongo_mapper rack-flash sinatra/base mustache/sinatra
  RedCloth chronic html_truncator tzinfo active_model/serializers
  active_support/inflector pony dotenv
}.each {|req| require req }

## Connect to MongoDB
MongoMapper.setup(
  {'production' => { 'uri' => ENV['MONGO_URI'] || 'mongodb://localhost:27017/roamtheblog' }},
  'production'
)

## Setup Pony
Pony.options = {
  :via => :smtp,
  :via_options => {
    :address => ENV['SMTP_HOST'],
    :port => ENV['SMTP_PORT'] || '587',
    :domain => ENV['SMTP_DOMAIN'],
    :user_name => ENV['SMTP_USER'],
    :password => ENV['SMTP_PASS'],
    :authentication => :plain,
    :enable_starttls_auto => true
  }
}

# Require app libs
Dir["./lib/*.rb"].sort.each {|req| require req}
Dir["./models/*.rb"].sort.each {|req| require req}
Dir["./app/*.rb"].sort.each {|req| require req}

# Create defaults
User.create_default
Site.create_default
