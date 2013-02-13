class Site
  include MongoMapper::Document

  key :location, String
  key :title, String, :default => 'My New Blog'
  key :domain, String, :default => 'example.com'
  key :timezone, String, :default => 'UTC'
  key :cache, Integer, :default => 300
  key :settings, Hash

  belongs_to :design
  belongs_to :page

  def self.setup
    User.create_default
    Design.create_default
    Site.create_default
    Post.create_default
  end

  def self.clean(really=false)
    return false unless really
    User.destroy_all
    Design.destroy_all
    Site.destroy_all
    Post.destroy_all
    Page.destroy_all
    Email.destroy_all
  end

  def self.create_default
    return false unless count == 0
    site = new
    site.settings['primary_color'] = '#295187'
    site.design = Design.first || Design.create_default
    site.save && site
  end

  def self.default
    first
  end

  def unset_page(page)
    update_attributes(:page_id => nil) if (page_id == page.id)
  end

end
