require 'fileutils'
worker_processes 4
timeout 30

## Create the tmp and log directories if not preset
@_path = File.expand_path(File.join(File.dirname(__FILE__), '..'))
FileUtils.mkdir_p("#{@_path}/tmp")
FileUtils.mkdir_p("#{@_path}/log")

## If unicorn is on the same server as nginx, use a unix socket
## If unicorn is on a different server than nginx, open a TCP Port
# listen "#{@_path}/tmp/unicorn.sock", :backlog => 1024
listen 5001

## Set the pid in the tmp dir
pid "#{@_path}/tmp/unicorn.pid"

## Set logging to log/application.log
stderr_path "#{@_path}/log/application.log"
stdout_path "#{@_path}/log/application.log"

__END__

Example Nginx Config

## If unicorn is on the same server as nginx, point to the unix socket
## If unicorn is on a different server than nginx, point to the IP and port
upstream myapp {
  server unix:/var/www/myapp/tmp/unicorn.sock fail_timeout=0;
  # server x.x.x.x:5001 fail_timeout=0;
}

...
location / {
  proxy_set_header  X-Real-IP  $remote_addr;
  proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header Host $http_host;
  proxy_redirect off;
  proxy_max_temp_file_size 0;
  if (!-f $request_filename) {
    proxy_pass http://myapp;
    break;
  }
}