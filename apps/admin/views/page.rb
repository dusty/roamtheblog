class AdminApp
  module Views
    class Page < Layout
      
      def new_page
        @page.new?
      end
      
      def page_action
        @page.new? ? "/admin/pages" : "/admin/pages/#{@page.slug}"
      end
      
      def page_method
        @page.new? ? "post" : "put"
      end

      def page_header
        @page.new? ? "New Page" : @page.title
      end
      
      def initialize
        create_getters_and_errors('page',%w{slug title body})
      end
      
    end
  end
end