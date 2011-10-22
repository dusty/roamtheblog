module Roam
  class App < Sinatra::Base

    configure do
      set :raise_errors, false
      set :dump_errors, true
      set :methodoverride, true
      set :show_exceptions, false
      set :static, true
      set :logging, Proc.new { ENV['RACK_ENV'] == "production" }
    end

    helpers do

      def check_active(path)
        "active" if request.path_info == path
      end

      def error_class(model,attribute)
        " error" unless model.errors[attribute].blank?
      end

      def errors_for(obj,method)
        obj.errors[method].first
      end

      def flash_messages
        out = ""
        [:warning, :error, :success, :info].each do |msg_type|
          unless flash[msg_type].blank?
            out += <<-EOD
<div class="alert-message #{msg_type} fade in" data-alert="alert">
  <a class="close" href="#">x</a>
  <p>#{flash[msg_type]}</p>
</div>
            EOD
          end
        end
        out
      end

      def site
        @site ||= Site.default
      end

      def post_path(post,stamp=false)
        path = "/blog/#{post.slug}"
        stamp ? (path + "?#{timestamp}") : path
      end

      def page_path(page,stamp=false)
        path = "/#{page.slug}"
        stamp ? (path + "?#{timestamp}") : path
      end

      def tag_path(tag)
        "/blog?tag=#{tag}"
      end

      def post_url(domain,post)
        "http://#{domain}#{get_post_path(post)}"
      end

      def short_date(date)
        date = parse_date(date)
        date ? date.strftime("%m/%d/%Y %l:%M %P") : ""
      end

      def long_date(date)
        date = parse_date(date)
        date ? date.strftime("%B #{date.day.ordinal}, %Y") : ""
      end

      def parse_date(date)
        return nil if date.blank?
        date = Chronic.parse(date) if date.is_a?(String)
        date ? date.in_time_zone : nil
      end

      def partial(page, locals={})
        erb(page, {:layout => false}, locals)
      end

      def options_for_select(options,selected=nil)
        output = ""
        options.each do |option|
          select = ""
          select = " selected=\"selected\"" if (selected.to_s == option[0].to_s)
          output += <<-EOD
    <option value="#{option[0]}"#{select}>#{option[1]}</option>\n
          EOD
        end
        output
      end

    end

  end
end