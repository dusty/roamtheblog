class UserApp
  module Views
    class Page < Layout
  
      def initialize(site, page)
        @site, @page = site, page
      end
      
      def site_title
        "#{site['title']} - #{@page['title']}"
      end
  
      def page_title
        @page['title']
      end
  
      def page_html
        @page.html
      end
      
    end
  end
end