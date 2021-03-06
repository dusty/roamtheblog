module Roam
  class UserApp
    module Views
      class Feed < Layout

        def title
          "RSS Feed"
        end

        def site_updated
          @updated.iso8601 rescue nil
        end

        def posts
          @posts.map do |post|
            {
              :title => post.title,
              :path => get_post_url(site_domain,post),
              :published => post.published_at.iso8601,
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
end