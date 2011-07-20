require 'fileutils'
FileUtils.mkdir_p("log")
FileUtils.mkdir_p("tmp")

worker_processes 4
timeout 30

@_path = File.expand_path(File.join(File.dirname(__FILE__), '..'))

listen "#{@_path}/tmp/unicorn.sock", :backlog => 1024
pid    "#{@_path}/tmp/unicorn.pid"

stderr_path "#{@_path}/log/application.log"
stdout_path "#{@_path}/log/application.log"