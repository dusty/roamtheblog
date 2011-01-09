class UserApp
  module Views
    class Layout < Mustache

      include ViewHelpers

      attr_reader :site
      
      def initialize(site)
        @site = site
        generate_dynamic_methods
      end
      
      def site_title
        site['title']
      end

      def site_domain
        site['domain']
      end
      
      ##
      # Dynamic Methods
      #
      # Create a site_#{key} method for each key in the Site.settings Hash
      # eg: $site.settings['monkey'] creates the site_monkey method
      def generate_dynamic_methods
        site['settings'].each do |k,v|
          self.class.class_eval do
            define_method(:"setting_#{k}") do
              site['settings'][k]
            end
          end
        end
      end
  
    end
  end
end