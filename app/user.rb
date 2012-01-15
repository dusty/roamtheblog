module Roam
  class UserApp < App

    # Require mustache views
    Dir["views/user/*.rb"].sort.each {|req| require req}

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
        @site ||= Site.default
      end

      def tags
        @tags ||= Post.tags
      end

      def design
        @design ||= site.design
      end

      def cache
        if site.cache && site.cache.to_i > 0
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
      #     User::Views::Page.new(:site => site, :page => page).render
      def mustache(template, args={}, layout=true)
        args = args.update(:site => site, :site_tags => tags)
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
      updated = Post.recent_update
      posts   = Post.recent(params[:limit])
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
      if page = site.page
        mustache(:page, {:page => page})
      else
        posts = Post.recent(5).all
        post  = posts.first
        posts.delete(post)
        mustache(:home, {:posts => posts, :post => post})
      end
    end

    get '/blog' do
      if site.page
        posts = Post.recent(5).all
        post  = posts.first
        posts.delete(post)
        mustache(:home, {:posts => posts, :post => post})
      else
        posts = Post.active(params[:tag]).all
        mustache(:blog, {:posts => posts, :tag => params[:tag]})
      end
    end

    get '/blog/:id' do
      not_found unless post = Post.by_slug(params[:id])
      posts = Post.near(post,2)
      mustache(:post, {:post => post, :posts => posts})
    end

    put '/blog/:id' do
      not_found unless post = Post.by_slug(params[:id])
      unless params[:comments].blank?
        puts "Potential Bot Post"
        redirect("/blog/#{params[:id]}")
      end
      comment = Comment.new(params[:comment])
      comment.ip = request.ip
      if comment.valid? && post.comments.push(comment) && post.save
        redirect("/blog/#{params[:id]}#comments")
      else
        posts = Post.near(post,2)
        mustache(:post, {:post => post, :posts => posts, :comment => comment})
      end
    end

    get '/:id' do
      not_found unless page = Page.by_slug(params[:id])
      mustache(:page, {:page => page})
    end

  end
end
