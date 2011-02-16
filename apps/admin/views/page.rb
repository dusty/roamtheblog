class AdminApp
  module Views
    class Page < Layout
      
      def new_page
        @page.new_record?
      end
      
      def page_action
        @page.new_record? ? "/admin/pages" : "/admin/pages/#{@page.slug}"
      end
      
      def page_method
        @page.new_record? ? "post" : "put"
      end

      def page_header
        @page.new_record? ? "New Page" : @page.title
      end
      
      def initialize
        create_getters_and_errors('page',%w{slug title body})
      end
      
    end
  end
end