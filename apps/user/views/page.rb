class UserApp
  module Views
    class Page < Layout
  
      def title
        @page['title']
      end
  
      def html
        @page.html
      end
      
    end
  end
end