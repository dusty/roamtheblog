class AdminApp
  module Views
    class User < Layout
      
      def page_header
        new_user ? "New User" : user_name
      end

      def page_action
        new_user ? "/admin/users" : "/admin/users/#{user_id}"
      end

      def page_method
       new_user ? "post" : "put"
      end

      def new_user
        @user.new?
      end
      
      def initialize
        create_getters_and_errors('user',%w{name login})
        create_error_getters('user',%w{password password_confirmation})
      end
      
      def user_id
        @user['_id'] 
      end
      
    end
  end
end