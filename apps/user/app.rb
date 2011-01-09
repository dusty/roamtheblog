# encoding: UTF-8

class UserApp < BaseApp
  
  not_found do
    mustache(:missing, site)
  end
  
  error do
    mustache(:error, site)
  end
  
  after do
    cache
  end
  
  helpers do
    
    def site
      @site ||= Site.first
    end
    
    def design
      site.design
    end
    
    def cache
      if site['cache'].to_i > 0
        response.headers['Cache-Control'] = "public, max-age=#{site['cache']}"
      end
    end
    
    ##
    # Render a mustache template
    #
    # Pass in the template name and the init arguments for the view
    #   mustache(:page, site, page)
    #   UserApp::Views::Page.new(site, page).render
    #
    # If the view subclasses Layout then it is rendered within the
    # layouts yield block
    #
    def mustache(template, *args)
      layout_class = UserApp::Views::Layout
      layout_class.template = design[:layout]
      view_class = UserApp::Views.const_get(template.to_s.classify)
      view_class.template = design[template]
      rendered = view_class.new(*args).render
      if view_class.superclass == layout_class
        layout_class.new(site).render(:yield => rendered)
      else
        rendered
      end
    end
    
  end
      
  before do
    UserApp::Views::Layout.template = design[:layout]
  end
  
  get '/index.xml' do
    content_type :xml
    updated = Post.recent(1).first['updated'].iso8601
    posts   = Post.active
    mustache(:feed, site, updated, posts)
  end
  
  get '/style.css' do
    content_type :css
    mustache(:style, site)
  end
  
  get '/application.js' do
    content_type :js
    mustache(:script, site)
  end

  get '/' do
    posts = Post.active.limit(5).to_a
    post  = posts.first
    mustache(:home, site, posts, post)
  end

  get '/blog' do
    posts = Post.active
    mustache(:blog, site, posts)
  end

  get '/blog/:id' do
    not_found unless post = Post.slug(params[:id])
    mustache(:post, site, post)
  end

  get '/:id' do
    not_found unless page = Page.slug(params[:id])
    mustache(:page, site, page)
  end

end