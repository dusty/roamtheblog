class UserApp
  module Views
    class Blog < Layout
    
      def initialize(site,posts)
        @site, @posts = site, posts
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