class UserApp
  module Views
    class Post < Layout
      
      def initialize(site, post)
        @site, @post = site, post
      end

      def post_slug
        @post['slug']
      end

      def post_url
        get_post_url(site_domain,@post)
      end

      def post_title
        @post['title']
      end

      def post_path
        get_post_path(@post)
      end

      def post_author
        @post['author']
      end

      def post_html
        @post.html
      end

      def post_date
        get_long_date(@post['date'])
      end
      
    end
  end
end