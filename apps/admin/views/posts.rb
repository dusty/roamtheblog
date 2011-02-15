class AdminApp
  module Views
    class Posts < Layout
      
      def nodate_posts
        map_posts(@nodate)
      end
      
      def future_posts
        map_posts(@future)
      end
      
      def active_posts
        map_posts(@active)
      end
        
      def map_posts(_posts)
        _posts.map do |post|
          {
            :post_date => get_short_date(post.published_at),
            :post_slug => post.slug,
            :post_title => post.title,
            :post_status => post.active? ? "Published" : "Pending"
          }
        end
      end
      
    end
  end
end