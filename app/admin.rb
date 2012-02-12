module Roam
  class AdminApp < BaseApp

    configure do
      use Rack::Session::Cookie, :secret => 'H1. Th1s 1s @ dirty s3cr3t j0y!'
      use Rack::Flash
      set :views, "views/admin"
    end

    not_found do
      erb :missing
    end

    error do
      erb :error
    end

    before do
      login_required
      Time.zone = site.timezone
      Chronic.time_class = Time.zone
    end

    helpers do
      def login_required
        case request.path_info
        when /^\/session/, /\/password/, /\/activation/
          return true
        else
          redirect '/admin/session' unless current_user
        end
      end

      def current_user
        @current_user ||= User.find(session[:user]) if session[:user]
      end

      def timezone_options
        us = ActiveSupport::TimeZone.us_zones
        nus = (ActiveSupport::TimeZone.all - ActiveSupport::TimeZone.us_zones)
        selected = ""
        (us + nus).map do |zone|
          if (site.timezone == zone.name) && selected.empty?
            selected = "selected=selected"
          else
            selected = ""
          end
          "<option value=\"#{zone.name}\" #{selected}>#{zone}</option>"
        end.join("\n")
      end

      def timestamp
        Time.now.to_i
      end

      def admin_post_path(post)
        post.new_record? ? "/admin/posts" : "/admin/posts/#{post.slug}"
      end

      def admin_page_path(page)
        page.new_record? ? "/admin/pages" : "/admin/pages/#{page.slug}"
      end

      def admin_design_path(design)
        design.new_record? ? "/admin/designs" : "/admin/designs/#{design.id}"
      end

      def admin_user_path(user)
        user.new_record? ? "/admin/users" : "/admin/users/#{user.id}"
      end

      def admin_design_status(design)
        if site.design == design
          <<-EOD
<span class="label success">Active</span>
          EOD
        else
          <<-EOD
<span class="label">
  <a href="#{admin_design_path(design)}" class="post_prompt"
     data-text="Make this design active?">Set Active</a>
</span>
          EOD
        end
      end

      def admin_design_copy_link(design)
        <<-EOD
<span class="label notice">
  <a href="/admin/designs/new?copy=#{design.id}" class="get_prompt"
     data-text="Copy the #{design.name} design?">Copy</a>
</span>
        EOD
      end

      def page_home_link(page)
        if site.page_id == page.id
          <<-EOD
<span class="label success">
    <a href="/admin/home/#{page.slug}" class="delete_prompt"
       data-text="Are you sure you want to unset this page?">Unset</a>
</span>
          EOD
        else
          <<-EOD
<span class="label">
    <a href="/admin/home/#{page.slug}" class="put_prompt"
       data-text="Are you sure you want to set this page?">Set</a>
</span>
          EOD
        end
      end

      def form_method(object)
        object.new_record? ? "post" : "put"
      end

    end

    get '/?' do
      redirect "/admin/posts"
    end

    get '/templates' do
      erb :templates
    end

    get '/textile' do
      erb :textile
    end

    get '/settings' do
      erb :settings
    end

    put '/settings' do
      if site.update_attributes(params[:site])
        flash.now[:success] = "Settings saved."
        erb :settings
      else
        flash.now[:error] = "Error saving settings."
        erb :settings
      end
    end

    post '/settings' do
      begin
        name = params[:setting][:name].slugize if params[:setting]
        value = params[:setting][:value] if params[:setting]
        raise(StandardError, "name cannot be empty") if name.empty?
        site.settings.update({name => value})
        if site.save
          flash.now[:success] = "Setting added."
          erb :settings
        else
          flash.now[:error] = "Error saving settings."
          erb :settings
        end
      rescue StandardError => e
        flash.now[:error] = e.message
        erb :settings
      end
    end

    delete '/settings/:id' do
      site.settings.delete(params[:id])
      if site.save
        flash[:warning] = "Setting removed."
        redirect '/admin/settings'
      else
        flash[:error] = "Error deleting setting."
        redirect '/admin/settings'
      end
    end

    get '/session' do
      current_user ? redirect('/admin') : erb(:login)
    end

    post '/session' do
      if user = User.authenticate(params[:login], params[:password])
        session[:user] = user.id.to_s
        user.record_login
        flash[:success] = "Login Successful."
        redirect '/admin'
      else
        flash.now[:error] = "Login Failed, please try again."
        erb :login
      end
    end

    delete '/session' do
      session.clear if current_user
      redirect '/admin'
    end

    get '/password' do
      current_user ? redirect("/") : erb(:password)
    end

    post '/password' do
      User.forgot_password(params[:email])
      flash[:warning] = 'An email will be sent with password reset instructions.'
      redirect '/admin/session'
    end

    get '/activation' do
      if user = User.authenticate_by_token(params[:email], params[:token])
        session[:user] = user.id
        flash[:warning] = 'Account activated, you may update your profile.'
        redirect "/admin/users/<%= user.id %>"
      else
        flash[:error] = 'Email or token is incorrect, please try again.'
        erb :password
      end
    end

    get '/posts' do
      @nodate  = Post.nodate.all
      @future  = Post.future.all
      @active  = Post.active.all
      erb :posts
    end

    get '/posts/new' do
      @post = Post.new
      @method = "post"
      @action = "/admin/posts"
      erb :post
    end

    post '/posts' do
      @post = Post.new
      @post.update_from_params(params[:post])
      @method = "post"
      @action = "/admin/posts"
      if @post.save
        flash[:success] = "Post created."
        redirect "/admin/posts/#{@post.slug}"
      else
        flash.now[:error] = "Error creating post."
        erb :post
      end
    end

    get '/posts/:id' do
      not_found unless @post = Post.by_slug(params[:id])
      @method = "put"
      @action = "/admin/posts/#{@post.slug}"
      erb :post
    end

    put '/posts/:id' do
      not_found unless @post = Post.by_slug(params[:id])
      @method = "put"
      @action = "/admin/posts/#{@post.slug}"
      @post.update_from_params(params[:post])
      if case
         when (params[:save] && @post.active?)
           @post.save_without_timestamps
         else
           @post.save
         end
        flash[:success] = "Post updated."
        redirect "/admin/posts/#{@post.slug}"
      else
        flash.now[:error] = "Error updating post."
        erb :post
      end
    end

    delete '/posts/:id' do
      not_found unless @post = Post.by_slug(params[:id])
      if @post.destroy
        flash[:warning] = "Post deleted."
        redirect '/admin/posts'
      else
        flash[:error] = "Error deleting post."
        redirect '/admin/posts'
      end
    end

    get '/pages' do
      @pages = Page.recent.all
      erb :pages
    end

    post '/pages' do
      @page = Page.new(params[:page])
      if @page.save
        flash[:success] = "Page created."
        redirect "/admin/pages/#{@page.slug}"
      else
        flash.now[:error] = "Error creating page."
        erb :page
      end
    end

    get '/pages/new' do
      @page = Page.new
      erb :page
    end

    get '/pages/:id' do
      not_found unless @page = Page.by_slug(params[:id])
      erb :page
    end

    put '/pages/:id' do
      not_found unless @page = Page.by_slug(params[:id])
      if @page.update_attributes(params[:page])
        flash[:success] = "Page updated."
        redirect "/admin/pages/#{@page.slug}"
      else
        flash.now[:error] = "Error updating page."
        erb :page
      end
    end

    delete '/pages/:id' do
      not_found unless @page = Page.by_slug(params[:id])
      if @page.destroy
        flash[:warning] = "Page deleted."
        redirect '/admin/pages'
      else
        flash[:error] = "Error deleting page."
        redirect '/admin/pages'
      end
    end

    put '/home/:id' do
      not_found unless @page = Page.by_slug(params[:id])
      if site.page = @page
        flash[:success] = "Page set as home."
        redirect '/admin/pages'
      else
        flash[:error] = "Error setting page as home."
        redirect '/admin/pages'
      end
    end

    delete '/home/:id' do
      not_found unless @page = Page.by_slug(params[:id])
      if site.unset_page(@page)
        flash[:success] = "Page unset as home."
        redirect '/admin/pages'
      else
        flash[:error] = "Error unsetting page as home."
        redirect '/admin/pages'
      end
    end

    get '/designs' do
      @designs = Design.recent.all
      erb :designs
    end

    post '/designs' do
      @design = Design.new(params[:design])
      if @design.save
        flash[:success] = "Design created."
        redirect "/admin/designs/#{@design.id}"
      else
        flash.now[:error] = "Error creating design."
        erb :design
      end
    end

    get '/designs/new' do
      if params[:copy]
        unless @design = Design.duplicate(params[:copy])
          flash[:error] = "Unable to copy design"
          redirect "/admin/designs"
        end
      else
        @design = Design.new
      end
      erb :design
    end

    get '/designs/:id' do
      not_found unless @design = Design.find(params[:id])
      erb :design
    end

    post '/designs/:id' do
      not_found unless design = Design.find(params[:id])
      if design.activate
        flash[:success] = "Design marked active."
        redirect "/admin/designs"
      else
        flash[:error] = "Error activating design."
        redirect "/admin/designs"
      end
    end

    put '/designs/:id' do
      not_found unless @design = Design.find(params[:id])
      if @design.update_attributes(params[:design])
        flash[:success] = "Design updated."
        redirect "/admin/designs/#{@design.id}"
      else
        flash.now[:error] = "Error updating design."
        erb :design
      end
    end

    delete '/designs/:id' do
      not_found unless design = Design.find(params[:id])
      if design.destroy
        flash[:warning] = "Design removed."
        redirect "/admin/designs"
      else
        flash[:error] = "Error removing design."
        redirect "/admin/designs"
      end
    end

    get '/users' do
      @users = User.recent.all
      erb :users
    end

    post '/users' do
      @user = User.new(params[:user])
      if @user.save
        flash[:success] = "User created."
        redirect "/admin/users/#{@user.id}"
      else
        flash.now[:error] = "Error creating user."
        erb :user
      end
    end

    get '/users/new' do
      @user = User.new
      erb :user
    end

    get '/users/:id' do
      not_found unless @user = User.find(params[:id])
      erb :user
    end

    put '/users/:id' do
      not_found unless @user = User.find(params[:id])
      if @user.update_attributes(params[:user])
        flash[:success] = "User updated."
        redirect "/admin/users/#{@user.id}"
      else
        flash.now[:error] = "Error updating user."
        erb :user
      end
    end

    delete '/users/:id' do
      begin
        not_found unless @user = User.find(params[:id])
        raise(StandardError, "Cannot delete yourself") if @user == current_user
        raise(StandardError, "Cannot delete only user") if User.count < 2
        if @user.destroy
          flash[:warning] = "User removed."
          redirect "/admin/users"
        else
          flash.now[:error] = "Error deleting user."
          erb :user
        end
      rescue StandardError => e
        flash.now[:error] = e.message
        erb :user
      end
    end

  end
end
