class AdminApp
  module Views
    class Users < Layout
      
      def users
        @users.map do |user|
          {
            :user_login => get_user_login(user),
            :user_name => user['name'],
            :user_last_login => get_short_date(user['last_login'])
          }
        end
      end
      
      private
      def get_user_login(user)
        <<-EOD
<a href="/admin/users/#{user['_id']}">#{user['login']}</a>
        EOD
      end
      
    end
  end
end