class UserApp
  module Views
    class Home < Layout
      
      def initialize(site, posts, post)
        @site, @posts, @post = site, posts, post
      end
      
      def title
        "#{site['title']} - #{@post['title']}"
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

      def posts
        @posts.map do |post| 
          { 
            :post_title => post['title'],
            :post_date => get_long_date(post['date']),
            :post_path => get_post_path(post)
          }
        end
      end

    end
  end
end