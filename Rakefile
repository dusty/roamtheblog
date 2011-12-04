task :init do
  require 'init'
end

desc "Run app in foreground"
task :run do
  sh "bundle exec thin start"
end

desc "Start app server"
task :start do
  sh "bundle exec thin start -C config/thin.yml"
end

desc "Stop app server"
task :stop do
  sh "bundle exec thin stop -C config/thin.yml"
end

desc 'Restart app server'
task :restart do
  sh "bundle exec thin stop -C config/thin.yml; bundle exec thin start -C config/thin.yml"
end

desc "Start app IRB session"
task :shell do
  sh "bundle exec racksh"
end