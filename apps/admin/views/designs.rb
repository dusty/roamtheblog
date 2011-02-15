class AdminApp
  module Views
    class Designs < Layout
      
      def designs
        @designs.map do |design|
          {
            :design_name => get_design_name(design),
            :design_status => get_design_status(design),
            :design_description => design.description,
            :design_copy => get_design_copy(design)
          }
        end
      end
      
      private
      def get_design_name(design)
        <<-EOD
<a href="/admin/designs/#{design.id}">#{design.name}</a>
        EOD
      end
      
      def get_design_status(design)
        if site.design == design
          "<strong>Active</strong>"
        else
          <<-EOD
<a href="/admin/designs/#{design.id}" class="post_prompt"
   rel="Make this design active?">Set Active</a>   
          EOD
        end
      end
      
      def get_design_copy(design)
        <<-EOD
<a href="/admin/designs/new?copy=#{design.id}" class="get_prompt"
   rel="Copy the #{design.name} design?">Copy</a>
        EOD
      end
      
    end
  end
end