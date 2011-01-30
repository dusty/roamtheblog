class UserApp
  module Views
    class Post < Layout

      def slug
        @post['slug']
      end

      def url
        get_post_url(site_domain,@post)
      end

      def title
        @post['title']
      end

      def path
        get_post_path(@post)
      end

      def author
        @post['author']
      end

      def html
        @post.html
      end

      def date
        get_long_date(@post['date'])
      end
      
    end
  end
end