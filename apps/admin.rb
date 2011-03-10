##
# AdminApp
class AdminApp < BaseApp

  register Mustache::Sinatra

  set :mustache, {
     :views     => 'views/admin/',
     :templates => 'templates/admin/'
  }

  configure do
    use Rack::Session::Cookie, :secret => 'H1. Th1s 1s @ dirty s3cr3t j0y!'
    use Rack::Flash
  end

  not_found do
    mustache :missing
  end

  error do
    mustache :error
  end

  before do
    @flash  = flash
    @site   = Site.default
    login_required
    Time.zone = site.timezone
    Chronic.time_class = Time.zone
  end

  helpers do
    def login_required
      return true if request.path_info.match(/^\/session/) || current_user
      redirect '/admin/session'
    end
    def current_user
      @current_user ||= User.by_id(session[:user]) if session[:user]
    end
    def site
      @site ||= Site.default
    end
  end

  get '/?' do
    redirect "/admin/posts"
  end

  get '/templates' do
    mustache :templates
  end

  get '/settings' do
    mustache :settings
  end

  put '/settings' do
    if site.update_attributes(params[:site])
      flash.now[:notice] = "Settings saved."
      mustache :settings
    else
      flash.now[:warning] = "Error saving settings."
      mustache :settings
    end
  end

  post '/settings' do
    begin
      name = params[:setting][:name].methodize if params[:setting]
      value = params[:setting][:value] if params[:setting]
      raise(StandardError, "name cannot be empty") if name.empty?
      site.settings.update({name => value})
      if site.save
        flash.now[:notice] = "Setting added."
        mustache :settings
      else
        flash.now[:warning] = "Error saving settings."
        mustache :settings
      end
    rescue StandardError => e
      flash.now[:warning] = e.message
      mustache :settings
    end
  end

  delete '/settings/:id' do
    site.settings.delete(params[:id])
    if site.save
      flash[:notice] = "Setting removed."
      redirect '/admin/settings'
    else
      flash[:warning] = "Error deleting setting."
      redirect '/admin/settings'
    end
  end

  get '/session' do
    if current_user
      flash[:notice] = "You are already logged in."
      redirect '/admin'
    else
      mustache :login
    end
  end

  post '/session' do
    if user = User.authenticate(params[:login], params[:password])
      session[:user] = user.id.to_s
      user.record_login
      flash[:notice] = "Login Successful."
      redirect '/admin'
    else
      flash.now[:warning] = "Login Failed, please try again."
      mustache :login
    end
  end

  delete '/session' do
    session.clear if current_user
    redirect '/admin'
  end

  get '/posts' do
    @nodate  = Post.nodate.to_a
    @future  = Post.future.to_a
    @active  = Post.active.to_a
    mustache :posts
  end

  get '/posts/new' do
    @post = Post.new
    mustache :post
  end

  post '/posts' do
    @post = Post.new(params[:post])
    if @post.save
      flash[:notice] = "Post created."
      redirect "/admin/posts/#{@post.slug}"
    else
      flash.now[:warning] = "Error creating post."
      mustache :post
    end
  end

  get '/posts/:id' do
    not_found unless @post = Post.by_slug(params[:id])
    mustache :post
  end

  put '/posts/:id' do
    not_found unless @post = Post.by_slug(params[:id])
    if @post.update_attributes(params[:post])
      flash[:notice] = "Post updated."
      redirect "/admin/posts/#{@post.slug}"
    else
      flash.now[:warning] = "Error updating post."
      mustache :post
    end
  end

  delete '/posts/:id' do
    not_found unless @post = Post.by_slug(params[:id])
    if @post.destroy
      flash[:notice] = "Post deleted."
      redirect '/admin/posts'
    else
      flash[:warning] = "Error deleting post."
      redirect '/admin/posts'
    end
  end

  get '/pages' do
    @_pages = Page.sort_updated.to_a
    mustache :pages
  end

  post '/pages' do
    @page = Page.new(params[:page])
    if @page.save
      flash[:notice] = "Page created."
      redirect "/admin/pages/#{@page.slug}"
    else
      flash.now[:warning] = "Error creating page."
      mustache :page
    end
  end

  get '/pages/new' do
    @page = Page.new
    mustache :page
  end

  get '/pages/:id' do
    not_found unless @page = Page.by_slug(params[:id])
    mustache :page
  end

  put '/pages/:id' do
    not_found unless @page = Page.by_slug(params[:id])
    if @page.update_attributes(params[:page])
      flash[:notice] = "Page updated."
      redirect "/admin/pages/#{@page.slug}"
    else
      flash.now[:warning] = "Error updating page."
      mustache :page
    end
  end

  delete '/pages/:id' do
    not_found unless @page = Page.by_slug(params[:id])
    if @page.destroy
      flash[:notice] = "Page deleted."
      redirect '/admin/pages'
    else
      flash[:warning] = "Error deleting page."
      redirect '/admin/pages'
    end
  end

  get '/designs' do
    @_designs = Design.sort_updated.to_a
    mustache :designs
  end

  post '/designs' do
    @design = Design.new(params[:design])
    if @design.save
      flash[:notice] = "Design created."
      redirect "/admin/designs/#{@design.id}"
    else
      flash.now[:warning] = "Error creating design."
      mustache :design
    end
  end

  get '/designs/new' do
    if params[:copy]
      unless @design = Design.duplicate(params[:copy])
        flash[:warning] = "Unable to copy design"
        redirect "/admin/designs"
      end
    else
      @design = Design.new
    end
    mustache :design
  end

  get '/designs/:id' do
    not_found unless @design = Design.by_id(params[:id])
    mustache :design
  end

  post '/designs/:id' do
    not_found unless design = Design.by_id(params[:id])
    if design.activate
      flash[:notice] = "Design marked active."
      redirect "/admin/designs"
    else
      flash[:warning] = "Error activating design."
      redirect "/admin/designs"
    end
  end

  put '/designs/:id' do
    not_found unless @design = Design.by_id(params[:id])
    if @design.update_attributes(params[:design])
      flash[:notice] = "Design updated."
      redirect "/admin/designs/#{@design.id}"
    else
      flash.now[:warning] = "Error updating design."
      mustache :design
    end
  end

  delete '/designs/:id' do
    not_found unless design = Design.by_id(params[:id])
    if design.destroy
      flash[:notice] = "Design removed."
      redirect "/admin/designs"
    else
      flash[:warning] = "Error removing design."
      redirect "/admin/designs"
    end
  end

  get '/users' do
    @_users = User.sort_logins.to_a
    mustache :users
  end

  post '/users' do
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "User created."
      redirect "/admin/users/#{@user.id}"
    else
      flash.now[:warning] = "Error creating user."
      mustache :user
    end
  end

  get '/users/new' do
    @user = User.new
    mustache :user
  end

  get '/users/:id' do
    not_found unless @user = User.by_id(params[:id])
    mustache :user
  end

  put '/users/:id' do
    not_found unless @user = User.by_id(params[:id])
    @user.password = params[:password]
    @user.password_confirmation = params[:password_confirmation]
    if @user.update_attributes(params[:user])
      flash[:notice] = "User updated."
      redirect "/admin/users/#{@user.id}"
    else
      flash.now[:warning] = "Error updating user."
      mustache :user
    end
  end

  delete '/users/:id' do
    begin
      not_found unless @user = User.by_id(params[:id])
      raise(StandardError, "Cannot delete yourself") if @user == current_user
      raise(StandardError, "Cannot delete only user") if User.count < 2
      if @user.destroy
        flash["notice"] = "User removed."
        redirect "/admin/users"
      else
        flash.now[:warning] = "Error deleting user."
        mustache :user
      end
    rescue StandardError => e
      flash.now[:warning] = e.message
      mustache :user
    end
  end

end
