class UserApp
  module Views
    class Blog < Layout
  
      def title
        "Blog Posts"
      end
      
      def posts
        @posts.map do |post| 
          { 
            :title => post['title'],
            :date => get_long_date(post['date']),
            :path => get_post_path(post)
          }
        end
      end

    end
  end
end