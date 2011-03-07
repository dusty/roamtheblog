# Bundler
require "rubygems"
require "bundler/setup"

# Include required gems
%w{
  mongo_odm rack-flash sinatra/base RedCloth mustache/sinatra chronic tzinfo
  html_truncator
}.each {|req| require req }

# Init mongo connection
config = {
  :host => ENV['MONGO_HOST'] || 'localhost',
  :port => ENV['MONGO_PORT'] || 27017,
  :database => ENV['MONGO_DB'] || 'roamtheblog'
}

# Authenticate if needed
if (ENV['MONGO_USER'] && ENV['MONGO_PASS'])
  config.update({
   :username =>  ENV['MONGO_USER'],
   :password => ENV['MONGO_PASS']
  })
end

MongoODM.config = config

# Require custom libraries
Dir["lib/**/*.rb"].sort.each {|req| require req}

# Require sinatra apps
Dir["apps/**/*.rb"].sort.each {|req| require req}

# Require mustache views
Dir["views/**/*.rb"].sort.each {|req| require req}

# Create defaults
User.create_default
Site.create_default