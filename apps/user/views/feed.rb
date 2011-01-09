class UserApp
  module Views
    class Feed < Mustache
      
      include ViewHelpers
      
      def initialize(site, updated, posts)
        @site, @updated, @posts = site, updated, posts
      end
      
      def site_domain
        @site['domain']
      end
  
      def site_title
        @site['title']
      end
  
      def site_updated
        @updated
      end
  
      def posts
        @posts.map do |post|
          {
            :post_title => post['title'],
            :post_path => get_post_url(site_domain,post),
            :post_published => post['date'].iso8601,
            :post_updated => post['updated'].iso8601,
            :post_author => post['author'],
            :post_summary => post.excerpt,
            :post_html => post.html
          }
        end
      end
      
    end
  end
end