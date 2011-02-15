class AdminApp
  module Views
    class Layout < Mustache
      
      include ViewHelpers

      def timestamp
        Time.now.to_i.to_s
      end
      
      def message_notice
        @flash['notice'] if @flash
      end

      def message_warning
        @flash['warning'] if @flash
      end
      
      def current_user
        @current_user
      end
       
      def site
        @site || Site.first
      end
            
      def site_title
        site.title
      end

      def site_domain
        site.domain
      end
  
      def site_location
        site.location
      end
      
      def site_cache
        site.cache
      end
      
      def site_timezone
        site.timezone
      end

      def timezones
        us = ActiveSupport::TimeZone.us_zones
        nus = (ActiveSupport::TimeZone.all - ActiveSupport::TimeZone.us_zones)
        selected = ""
        (us + nus).map do |zone|
          if (site_timezone == zone.name) && selected.empty?
            selected = "selected=selected"
          else
            selected = ""
          end
          {:option => "<option value=\"#{zone.name}\" #{selected}>#{zone}</option>"}
        end
      end
      
      def site_settings
        site.settings.map { |k,v| {:name => k, :value => v} }
      end
      
      def initialize
        super
        dynamic_settings
      end

      private
      ##
      # Dynamic Settings
      #
      # Create a site_#{key} method for each key in the Site.settings Hash
      # eg: $site.settings['monkey'] creates the site_monkey method
      def dynamic_settings
        site.settings.each do |k,v|
          self.class.class_eval do
            define_method(:"setting_#{k}") do
              site.settings[k]
            end
          end
        end
      end
      
    end
  end
end