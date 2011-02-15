class UserApp < BaseApp
  
  not_found do
    mustache(:missing, {})
  end
  
  error do
    mustache(:error, {})
  end
  
  after do
    cache
  end
  
  helpers do
    
    def site
      @site ||= Site.first
    end
    
    def design
      site.active_design
    end
    
    def cache
      if site.cache && site.cache > 0
        response.headers['Cache-Control'] = "public, max-age=#{site.cache}"
      end
    end
    
    ##
    # Render a mustache template
    #
    # Pass in the view name and the init arguments for that view
    # Pass layout=false if you do not wish to render the layout template
    #
    # The site variable is added automatically as it is required
    #   mustache(:page, :page => page)
    #   UserApp::Views::Page.new(:site => site, :page => page).render
    def mustache(template, args={}, layout=true)
      args = args.update(:site => site)
      layout_class = UserApp::Views::Layout
      layout_class.template = design.layout
      view_class = UserApp::Views.const_get(template.to_s.classify)
      view_class.template = design.send(template)
      view_initialized = view_class.new(args)
      view_rendered = view_initialized.render
      if layout
        if view_initialized.respond_to?(:title)
          args.update(:page_title => view_initialized.title)
        end
        layout_class.new(args).render(:yield => view_rendered)
      else
        view_rendered
      end
    end
    
  end
      
  before do
    UserApp::Views::Layout.template = design.layout
  end
  
  get '/index.xml' do
    content_type :xml
    updated = Post.recent.first.updated_at.iso8601
    posts   = Post.active
    mustache(:feed, {:updated => updated, :posts => posts}, false)
  end
  
  get '/style.css' do
    content_type :css
    mustache(:style, {}, false)
  end
  
  get '/application.js' do
    content_type :js
    mustache(:script, {}, false)
  end

  get '/' do
    posts = Post.active.limit(5).to_a
    post  = posts.first
    mustache(:home, {:posts => posts, :post => post})
  end

  get '/blog' do
    posts = params[:tag] ? Post.tag(params[:tag]).to_a : Post.active.to_a
    mustache(:blog, {:posts => posts, :tag => params[:tag]})
  end

  get '/blog/:id' do
    not_found unless post = Post.slug(params[:id])
    args = {:post => post}
    mustache(:post, args)
  end

  get '/:id' do
    not_found unless page = Page.slug(params[:id])
    mustache(:page, {:page => page})
  end

end