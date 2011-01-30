class UserApp
  module Views
    class Layout < Mustache

      include ViewHelpers
      
      def initialize(args={})
        args.each {|k,v| instance_variable_set("@#{k.to_s}",v)}
        generate_dynamic_methods
      end
      
      ##
      # Page title
      #
      # If the @page_title variable is set make the page_title 
      # "My Blog - My Page", otherwise, just make it "My Blog"
      def page_title
        @page_title ? "#{site_title} - #{@page_title}" : site_title
      end
      
      ##
      # Site variables
      #
      # These variables are usable site_wide
      def site_title
        @site['title']
      end

      def site_domain
        @site['domain']
      end
      
      def site_location
        @site['location']
      end
      
      ##
      # Dynamic Methods
      #
      # Create a site_#{key} method for each key in the Site.settings Hash
      # eg: $site.settings['monkey'] creates the site_monkey method
      def generate_dynamic_methods
        @site['settings'].each do |k,v|
          self.class.class_eval do
            define_method(:"setting_#{k}") do
              @site['settings'][k]
            end
          end
        end
      end
  
    end
  end
end