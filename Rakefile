require 'rake/testtask'
require 'fileutils'

Rake::TestTask.new do |t|
  t.pattern = "test/*_test.rb"
end

desc "Setup defaults"
task :setup do
  sh 'bundle exec ruby -r ./app -e "Site.setup"'
end

desc "Run shell"
task :shell do
  sh "bundle exec irb -r ./app"
end

desc "Run server"
task :server do
  sh "bundle exec puma -t 8:16"
end
