class UserApp
  module Views
    class Post < Layout

      def slug
        @post.slug
      end

      def url
        get_post_url(site_domain,@post)
      end

      def title
        @post.title
      end

      def path
        get_post_path(@post)
      end

      def author
        @post.author
      end

      def html
        @post.html
      end

      def date
        get_long_date(@post.published_at)
      end

      def has_tags?
        !@post.tags.empty?
      end

      def tag_list
        @post.tags.map do |tag|
          {
            :tag => tag,
            :path => get_tag_path(tag),
            :first? => @post.tags.first == tag,
            :last? => @post.tags.last == tag
          }
        end
      end

      def posts
        @posts
      end

      def younger
        @posts[:younger].map do |post|
          {
            :title => post.title,
            :date => get_long_date(post.published_at),
            :path => get_post_path(post)
          }
        end
      end

      def older
        @posts[:older].map do |post|
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
