class UserApp
  module Views
    class Feed < Layout
  
      def title
        "RSS Feed"
      end
      
      def posts
        @posts.map do |post|
          {
            :title => post.title,
            :path => get_post_url(site_domain,post),
            :published => post.publish_at.iso8601,
            :updated => post.updated_at.iso8601,
            :author => post.author,
            :summary => post.excerpt,
            :html => post.html
          }
        end
      end
      
    end
  end
end