# Bundler
require "rubygems"
require "bundler/setup"

# Include required gems
%w{
  mongo_mapper rack-flash sinatra/base mustache/sinatra RedCloth chronic html_truncator tzinfo
  active_support/inflector pony
}.each {|req| require req }

# Require custom libraries
Dir["./lib/**/*.rb"].sort.each {|req| require req}

## Connect to MongoDB
MongoMapper.setup(
  {'production' => {'uri' => ENV['MONGOLAB_URI'] || 'mongodb://localhost:27017/roamtheblog'}}, 'production'
)

## Setup Pony
Pony.options = {
  :via => :smtp,
  :via_options => {
    :address => 'smtp.sendgrid.net',
    :port => '587',
    :domain => ENV['SENDGRID_DOMAIN'] || 'localhost.localdomain',
    :user_name => ENV['SENDGRID_USERNAME'],
    :password => ENV['SENDGRID_PASSWORD'],
    :authentication => :plain,
    :enable_starttls_auto => true
  }
}

# Require sinatra apps
Dir["./models/*.rb"].sort.each {|req| require req}
Dir["./app/*.rb"].sort.each {|req| require req}

# Create defaults
User.create_default
Site.create_default
