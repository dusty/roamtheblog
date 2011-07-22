task :init do
  require 'init'
end

desc "Create indexes"
task :index => :init do
  [Design, Page, Post, Site, User].each { |model| model.create_indexes }
end
