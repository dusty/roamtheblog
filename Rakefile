task :init do
  require 'init'
end

desc 'Run shell'
task :shell do
  sh 'bundle exec racksh'
end

desc "Run app in foreground"
task :run do
  sh 'bundle exec passenger start'
end

desc "Start app server"
task :start do
  sh 'bundle exec passenger start -d'
end

desc "Stop app server"
task :stop do
  sh 'bundle exec passenger stop'
end

desc "Stop app server"
task :restart => [:stop, :start]