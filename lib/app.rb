module Roam
  class App < Sinatra::Base

    configure do
      set :raise_errors, false
      set :dump_errors, true
      set :methodoverride, true
      set :show_exceptions, false
      set :static, true
      set :logging, Proc.new { ENV['RACK_ENV'] == "production" }
      set :public, "public"
    end

  end
end