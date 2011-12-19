Simple Blog/CMS Software that runs http://roamthepla.net.

Built With:
  * Ruby (https://github.com/ruby/ruby)
  * Sinatra (https://github.com/sinatra/sinatra)
  * Mustache (https://github.com/defunkt/mustache)
  * RedCloth (https://github.com/jgarber/redcloth)
  * MongoDB (https://github.com/mongodb/mongo)
  * MongoMapper (https://github.com/jnunemaker/mongomapper)
  * Twitter Bootstrap (https://github.com/twitter/bootstrap)

Default template setup for use with:
  * Disqus
  * Google Analytics
  * Feedburner
  * Facebook
  * Twitter
  * YouTube
  * SmugMug

Markup
  Roamtheblog makes it easy to create a website and/or blog by using the
  Textile markup language.  With Textile you can create HTML code without
  needing to write HTML (although you can).

Requirements
  Roamtheblog saves its data to a MongoDB database.  If you don't want to run your
  own, I recommend using MongoLab (mongolab.com) or MongoMachine (mongomachine.com).
  MongoLab in particular offers a free database version that will cover your blog
  for quite some time.

  You must have ruby, git, and the bundler rubygem installed on the machine
  that will be running your blog.  If you don't want to run your own, I
  recommend using Heroku (heroku.com).

  If you are going to deploy to Heroku, you must also install the heroku rubygem.
  Please see heroku.com for more instructions.

Optimizations
  Roamtheblog is optimized to run on Heroku by setting a Cache-Control header
  to 300 seconds by default.  You can adjust that number as you wish in the
  Settings panel.

  Heroku or any other host that runs a cache such as Varnish in front of your
  app, will honor this setting and cache pages for this long. This means your
  app is only hit once every 5 minutes for each page.  The rest of the
  requests are served by the cache server.

  This will speed up the site and help to keep your Heroku account from
  being overwhelmed by limiting the number of requests that your app serves.

MongoDB
  If you are running this locally or on your own server, you will need to have
  mongodb up and running. Please see mongodb.org for more information on
  downloading, installing, and running mongodb.

  If you are running on Heroku, you may will need a mongodb instance that is
  accessible over the internet.  Check out http://mongolab.com if you
  are looking for an affordable and reliable mongodb host.

  By default, roamtheblog uses the default of "localhost" port "27017" and
  a database named "roamtheblog".  If this is good for you, then no changes
  are needed.

  If you want to make changes, you may set the following environmental
  variables to override whichever settings you need to.

  MONGO_HOST: hostname or IP address of the server
  MONGO_PORT: port to connect to
  MONGO_DB:   database name
  MONGO_USER: username to login with
  MONGO_PASS: password to login with

Rakefile
  The rakefile contains some handy commands to manage your app from the command-line

    rake run   - will run your app locally listening on port 3000
    rake start - will start your app as a daemon, to be used on your server
    rake stop  - will stop your app if running as a daemon
    rake shell - opens an IRB prompt with your app fully loaded

Running Locally:
  Must have mongod running and git and bundler installed.

  # git clone https://github.com/dusty/roamtheblog.git
  # cd roamtheblog
  # bundle install --path tmp/
  # rake run

  You can now see the blog at http://localhost:3000

Running on Heroku:
  Must have git, bundler, and heroku gem installed.  Note, you must add your mongodb
  connection information as heroku config variables.

  # git clone https://github.com/dusty/roamtheblog.git
  # cd roamtheblog
  # heroku create YOURAPPNAME --stack bamboo-mri-1.9.2
  # heroku config:add MONGO_HOST=xx MONGO_PORT=xx MONGO_DB=xx MONGO_USER=xx MONGO_PASS=xx
  # git push heroku master

  You can now see the blog at http://YOURAPPNAME.heroku.com

Running on your server:
  If you are not pointing to a local mongodb server with a database named roamtheblog,
  then you will need to prefix the rake command with your mongodb connection information.

  # cd /the/path/to/your/app
  # git clone https://github.com/dusty/roamtheblog.git
  # cd roamtheblog
  # bundle install --path tmp/
  # MONGO_HOST=xxxx MONGO_PORT=xx MONGO_DB=xx MONGO_USER=xx MONGO_PASS=xx rake start

Admin Panel

  Go to the admin panel (/admin) to manage your site.  By default the
  username and password is 'admin' (without the quotes).  After you login
  for the first time, you should change both settings.

  Pages
    Create static pages that are not blog posts such as an About page.
    Pages have a URL based on the title, such as /about.  You may set
    a page as the homepage, which will override the blog as the homepage.
    This could be handy if you are using roamtheblog as a webpage with
    a blog component.

  Posts
    Create blog posts.  You can assign a publish date to automatically
    publish posts at a later date, or leave it blank to keep the post
    unpublished.

    Blog posts have a URL based on the publish date and the title, such
    as /blog/20110101-my-post.

  Settings
    Setup system-wide variables such as domain, title, and cache timeout.
    Be sure to set the desired Time Zone for publishing articles in the
    future.

    In addition, you can setup custom variables for use within
    each template.  For example, if you create a setting named 'flickr'
    with the value of 'myflickrid', then you can use {{setting_flickr}}
    in any of your templates and it will be replaced with the value of
    'myflickrid'

  Designs
    You can create a design for displaying the html of your pages.  By
    default a copy of the design used on roamthepla.net is included.  You
    can copy this design and make changes to it, or create your own.
    Whenever you like you can switch between designs in the admin panel.

    Each design uses the markup language called Mustache for rendering the
    html.  Mustache allows you to write html using variables and arrays to
    control the content.

    For more information, please refer to the Mustache documentation at:
    http://mustache.github.com/mustache.5.html

  Users
    Add and manage users that can login and create content on the site.


Templates
  Each Design requires templates of certain names used to render different
  types of pages.  Below is a list of templates found in a design,
  the URL used to access that page (if applicable), and a brief description.

  Layout
    The main layout of the site, typically the header, footer, and navbar.

  Error
    The content that is presented when there is an error

  Missing
    The content provided when a page is not found

  Blog
    Lists all the posts on this blog.

  Feed
    Provides XML output of the posts for an RSS feed

  Home
    The main page of the blog, showing only the most recent post

  Page
    Static pages that are not a blog post, such as an About page

  Post
    Shows a blog post in its entirety

  Script
    Any custom javascript code

  Style
    The CSS Stylesheet for the site

Routes
  /index.xml
    Displays the Feed template with an XML content-type

  /application.js
    Displays the Script template with a javascript content-type

  /style.css
    Displays the Style template with a css content-type

  /
    If setup with a page as the homepage, this will show the Page template for that page.
    Otherwise, it will show the Home template with the most recent blog post.

  /blog
    If setup with a page as the homepage, this will show the Blog template listing all posts.
    Otherwise, it will show the Home template with the most recent blog post.

  /posts
    Shows the Blog template listing all posts.

  /blog/:postname (eg: /blog/20110101-my-blog-post)
    Shows the Post template with the post that has the same name.

  /posts/:postname (eg: /posts/20110101-my-blog-post)
    Same as above.  Shows the Post template with the post that has the same name.

  /:pagename  (eg: /about)
    Shows the Page template with the page that has the same name.

Variables
  Each template is able to use certain mustache variables to provide content.
  Please refer to the Mustache documentation for more explanation on how
  to use variables.

  You can find the Mustache documentation with more details at:
  http://mustache.github.com/mustache.5.html

  Site-Wide:
    setting_xxxx: variables added in the Settings panel, prefixed by _setting
    site_domain: domain of the site (eg: mydomain.com)
    site_title: title of site
    site_location: location of the site or authors of the site
    site_map: link to a google map view based on the site_location
    site_has_tags?: boolean indicating if there are any tags
    site_tags: array of all tags
      tag: name of the tag (ruby)
      path: path to a list of all posts with that tag

  Style, Script, Error, Missing
    No special variables, however, all site-wide variables are accessible.
    eg: you could set a primary_color variable in settings and
    access that with {{setting_primary_color}} in your stylesheet.

  Feed (RSS Feed)
    updated: date of last update to any article
    posts: an array of posts that each contain:
      title: title of the post
      path: full URL to the post
      published: publish date of the post
      updated: last date this post was updated
      author: author of the post
      summary: summary of the post
      html: full html of the post

  Home (Main page of the site):
    slug: slug/permalink of the post (eg: 20110103-mypost)
    title: title of the post
    path: relative URL to the post
    author: author of this post
    date: date of the post
    has_tags?: boolean indicating if the post has tags
    tag_list: an array of tags associated with this post
      tag: name of tag
      path: path to a list of all posts with this tag
    posts: an array of recent posts ordered by date
      title: title of the post
      date: date of the post
      path: relative URL to the post

  Blog (List of All Articles):
    filtered?: boolean indicating if the search is filtered
    posts: an array of all posts ordered by date
       title: title of the post
       date: date of the post
       path: relative URL to the post

  Page (Static Page):
    title: title of the Page
    html: full HTML of the page

  Post (Blog Post):
    slug: slug/permalink of the post (eg: 20110103-mypost)
    url: full URL to the post
    path: relative URL to the post
    title: title of the post
    author: author of the post
    html: full HTML of the page
    date: date of the post
    has_tags?: boolean indicating if the post has tags
    tag_list: an array of tags associated with this post
      tag: name of tag
      path: path to a list of all posts with this tag
    younger: an array of recent younger posts ordered by date
      title: title of the post
      date: date of the post
      path: relative URL to the post
    older: an array of recent older posts ordered by date
      title: title of the post
      date: date of the post
      path: relative URL to the post


Default Template
  The default template is a clean and clutter-free template used to power
  roamthepla.net.  Feel free to use it, or copy it and modify it as you
  wish.

  There are several settings built in to the default template that rely on
  user submitted variables.  Just create them in the Settings panel and add
  the value you want.  Once those settings are added, the features will be
  activated in the layout.

  Enhancements
    feedburner: enable feedburner RSS feeds with your feedburner id.
    analytics: track page visits with your google analytics id.
    disqus: use disqus for comments with your disqus id.

  Links (on bottom of pages)
    facebook: link to your facebook site/page
    twitter: link to your twitter page
    youtube: link to your youtube account
    flickr: link to your flickr account
    picasa: link to your picasa account
    smugmug: link to your smugmug account
    500px: link to your 500px account

FAQ
  Q. How do I make a Page as the homepage instead of the last blog post?
  A. In the Pages section of the Admin panel, click on the "Set" link under the
     Home column listing all the pages.  See the Routes section above to see how
     that changes the routes.  To reverse this action, click Unset next to the Page
     that is set.

  Q. How do I format a blog post or page?
  A. Roamtheblog uses the Textile markup to make it easy to write
     HTML pages without having to understand or use HTML.  When you click
     on the New link to create a Page or Post, there are links to instructions
     on how to use the Textile markup language.

  Q. How can I add a picture or video to my page or blog post?
  A. Roamtheblog is as simple as it can be and does not manage media.  I
     recommend using a site that specializes in that, such as SmugMug, Flickr,
     Picasa, YouTube, etc....

     For example, when you've uploaded a picture to Flickr, you can share that
     picture.  One of the options will give you a link to copy/paste into
     your blog post.  You can choose the size you'd like and just copy/paste
     that code into your post.

  Q. How can I add a logo to my site?
  A. You need a direct link to the image.  If you are using the default
     template you can simply add that URL to a setting named 'logo' in the
     Settings panel.

     To find a direct link to an image on Flickr, you will need to
     right-click and open the image in a new window/tab.  Then copy/paste
     the URL in the location bar of your browser.  This will give you a direct
     URL to the image, instead of a URL to the flickr page.

  Q. How do I reset my password?
  A. Ask another admin to do it for you using the admin panel.  If you are
     the only admin and you've forgotten your password, then you can change
     the data stored in the database.
       # cd /the/path/to/your/app
       # heroku console
       # u = User.by_login('yourlogin')
       # u.password = 'yournewpass'
       # u.password_confirmation = 'yournewpass'
       # u.save

  Q. Why did you write this?
  A. My wife and I are traveling around and blogging about it for our
     friends and family.  We were frustrated with Wordpress and didn't know
     of any simple alternatives that were easy to use for non-geeks (my wife).
     So I wrote this myself while we were traveling.

  Q. Why did you release it as open source?
  A. This is for someone that wants to learn about Ruby, Sinatra, or MongoDB.

  Q. What if I don't understand these instructions?
  A. Give it a shot.  Send me an email if you are have problems and I might be
     able to offer some advice.
