##
# AdminApp
class AdminApp < BaseApp
  
  register Mustache::Sinatra
  
  set :mustache, {
     :views     => 'apps/admin/views/',
     :templates => 'apps/admin/templates/'
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
    @site   = Site.first
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
      @site ||= Site.first
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
    begin
      site.update_attributes!(params[:site])
      flash.now[:notice] = "Settings saved."
      mustache :settings
    rescue StandardError => e
      flash.now[:warning] = "Error saving settings."
      mustache :settings
    end
  end
  
  post '/settings' do
    begin      
      name = params[:setting][:name].methodize if params[:setting]
      value = params[:setting][:value] if params[:setting]
      raise(StandardError, "Name cannot be empty.") if name.empty?
      site.settings.update({name => value})
      site.save!
      flash.now[:notice] = "Setting added."
      mustache :settings
    rescue StandardError => e
      flash.now[:warning] = "Error saving settings."
      mustache :settings      
    end
  end
  
  delete '/settings/:id' do
    begin
      site.settings.delete(params[:id])
      site.save!
      flash[:notice] = "Setting removed."
      redirect '/admin/settings'
    rescue StandardError => e
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
    begin
      if user = User.authenticate(params[:login], params[:password])
        session[:user] = user.id
        user.update_attributes!(:last_login => Time.now.utc)
        flash[:notice] = "Login Successful."
        redirect '/admin'
      else
        flash.now[:warning] = "Login Failed, please try again."
        mustache :login
      end
    rescue StandardError => e
      redirect '/admin'
    end
  end

  delete '/session' do
    session.clear if current_user
    redirect '/admin'
  end

  get '/posts' do
    @nodate  = Post.nodate
    @future  = Post.future
    @active  = Post.active
    mustache :posts
  end
  
  get '/posts/new' do
    @post = Post.new
    mustache :post
  end
  
  post '/posts' do
    begin
      @post = Post.new(params[:post])
      @post.published_at = params[:post][:published_at]
      @post.save!
      flash[:notice] = "Post created."
      redirect "/admin/posts/#{@post.slug}"
    rescue StandardError => e
      flash.now[:warning] = "Error creating post."
      mustache :post
    end
  end
  
  get '/posts/:id' do
    not_found unless @post = Post.by_slug(params[:id])
    mustache :post
  end
  
  put '/posts/:id' do
    begin
      not_found unless @post = Post.by_slug(params[:id])
      @post.published_at = params[:post][:published_at]
      @post.update_attributes!(params[:post])
      flash[:notice] = "Post updated."
      redirect "/admin/posts/#{@post.slug}"
    rescue StandardError => e
      flash.now[:warning] = "Error updating post."
      mustache :post
    end
  end
  
  delete '/posts/:id' do
    begin
      not_found unless @post = Post.by_slug(params[:id])
      @post.destroy
      flash[:notice] = "Post deleted."
      redirect '/admin/posts'
    rescue StandardError => e
      flash[:warning] = "Error deleting post."
      redirect '/admin/posts'
    end
  end
  
  get '/pages' do
    @pages = Page.all
    mustache :pages
  end
  
  post '/pages' do
    begin
      @page = Page.new(params[:page])
      @page.save!
      flash[:notice] = "Page created."
      redirect "/admin/pages/#{@page.slug}"
    rescue StandardError => e
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
    begin
      not_found unless @page = Page.by_slug(params[:id])
      @page.update_attributes!(params[:page])
      flash[:notice] = "Page updated."
      redirect "/admin/pages/#{@page['slug']}"
    rescue StandardError => e
      flash.now[:warning] = "Error updating page."
      mustache :page
    end
  end

  delete '/pages/:id' do
    begin
      not_found unless @page = Page.by_slug(params[:id])
      @page.destroy
      flash[:notice] = "Page deleted."
      redirect '/admin/pages'
    rescue StandardError => e
      flash[:warning] = "Error deleting page."
      redirect '/admin/pages'      
    end
  end
  
  get '/designs' do
    @designs = Design.all
    mustache :designs
  end
  
  post '/designs' do
    begin
      @design = Design.new(params[:design])
      @design.save!
      flash[:notice] = "Design created."
      redirect "/admin/designs/#{@design.id}"
    rescue StandardError => e
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
    begin
      not_found unless design = Design.by_id(params[:id])
      design.activate
      flash[:notice] = "Design marked active."
      redirect "/admin/designs"
    rescue StandardError => e
      flash[:warning] = "Error activating design."
      redirect "/admin/designs"
    end
  end
  
  put '/designs/:id' do
    begin
      not_found unless @design = Design.by_id(params[:id])
      @design.update_attributes!(params[:design])
      flash[:notice] = "Design updated."
      redirect "/admin/designs/#{@design.id}"
    rescue StandardError => e
      flash.now[:warning] = "Error updating design."
      mustache :design
    end
  end
  
  delete '/designs/:id' do
    begin
      not_found unless design = Design.by_id(params[:id])
      design.destroy
      flash[:notice] = "Design removed."
      redirect "/admin/designs"
    rescue StandardError => e
      flash[:warning] = "Error removing design."
      redirect "/admin/designs"
    end
  end
  
  get '/users' do
    @users = User.find
    mustache :users
  end
  
  post '/users' do
    begin
      @user = User.new(params[:user])
      @user.save!
      flash[:notice] = "User created."
      redirect "/admin/users/#{@user.id}"
    rescue StandardError => e
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
    begin
      not_found unless @user = User.by_id(params[:id])
      @user.password = params[:password]
      @user.password_confirmation = params[:password_confirmation]
      @user.update_attributes!(params[:user])
      flash[:notice] = "User updated."
      redirect "/admin/users/#{@user.id}"
    rescue StandardError => e
      flash.now[:warning] = "Error updating user."
      mustache :user
    end
  end
  
  delete '/users/:id' do
    begin
      not_found unless @user = User.by_id(params[:id])
      raise(StandardError, "Cannot delete yourself") if @user == current_user
      raise(StandardError, "Cannot delete only user") if User.count < 2
      @user.destroy
      flash["notice"] = "User removed."
      redirect "/admin/users"
    rescue StandardError => e
      flash.now[:warning] = "Error deleting user."
      mustache :user
    end
  end
  
end