module Roam
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

        def datetime
          get_datetime(@post.published_at)
        end

        def has_tags?
          !@post.tags.empty?
        end

        def active?
          @post.active?
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
              :datetime => get_datetime(post.published_at),
              :path => get_post_path(post)
            }
          end
        end

        def older
          @posts[:older].map do |post|
            {
              :title => post.title,
              :date => get_long_date(post.published_at),
              :datetime => get_datetime(post.published_at),
              :path => get_post_path(post)
            }
          end
        end

        def comments
          @post.comments.map do |comment|
            {
              :name => comment.name,
              :comment => comment.comment,
              :date => get_long_date(comment.created_at),
              :datetime => get_datetime(comment.created_at),
              :url => comment.url
            }
          end
        end

        def comments_count
          @post.comments.count
        end

        def comment_name
          @comment.name if @comment
        end

        def comment_email
          @comment.email if @comment
        end

        def comment_comment
          @comment.comment if @comment
        end

        def comment_url
          @comment.url if @comment
        end

        def comment_errors?
          !comment_errors.blank?
        end

        def comment_errors
          @comment.errors.full_messages.map do |error|
            {
              :message => error
            }
          end if @comment
        end

      end
    end
  end
end
