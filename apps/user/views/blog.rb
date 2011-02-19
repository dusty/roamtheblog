class UserApp
  module Views
    class Blog < Layout
  
      def title
        "Blog Posts"
      end
      
      def search
        if @tag.empty?
          "All Posts"
        else
          "Posts tagged #{@tag}"
        end
      end
      
      def filtered?
        !@tag.empty?
      end
      
      def posts
        @posts.map do |post| 
          { 
            :title => post.title,
            :date => get_long_date(post.published_at),
            :path => get_post_path(post)
          }
        end
      end

    end
  end
end