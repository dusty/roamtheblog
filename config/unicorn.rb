require 'fileutils'
worker_processes 4
timeout 30

@_path = File.expand_path(File.join(File.dirname(__FILE__), '..'))
FileUtils.mkdir_p("#{@_path}/tmp")
FileUtils.mkdir_p("#{@_path}/log")


listen "#{@_path}/tmp/unicorn.sock", :backlog => 1024
pid    "#{@_path}/tmp/unicorn.pid"

stderr_path "#{@_path}/log/application.log"
stdout_path "#{@_path}/log/application.log"

__END__

  Example Nginx Config

  upstream myapp {
    server  unix:/var/www/myapp/tmp/unicorn.sock;
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
  ...

