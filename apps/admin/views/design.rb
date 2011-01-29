class AdminApp
  module Views
    class Design < Layout
      
      def page_header
        new_design ? "New Design" : design_name
      end
      
      def page_action
        new_design ? "/admin/designs" : "/admin/designs/#{design_id}"
      end
      
      def page_method
       new_design ? "post" : "put"
      end
      
      def new_design
        @design.new?
      end
      
      def design_id
        @design['_id']
      end
      
      def initialize
        create_getters_and_errors('design', %w{ name description layout blog home page 
          post feed missing error style script })
      end
      
    end
      
  end
end