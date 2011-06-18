class Site
  include MongoMapper::Document

  key :location, String
  key :title, String, :default => 'My New Blog'
  key :domain, String, :default => 'example.com'
  key :timezone, String, :default => 'UTC'
  key :cache, Integer, :default => 300
  key :settings, Hash, :default => {}
  key :design_id, String
  key :page_id, String
  timestamps!

  def self.create_default
    return false unless count == 0
    site = new
    site.settings = {}
    site.settings['primary_color'] = '#295187'
    site.save && site
  end

  def self.default
    first
  end

  ##
  # Return the associated design if it exists
  # If not assign the next design or create a default
  def design
    unless design_id && _design = Design.by_id(design_id)
      _design = Design.first || Design.create_default
      self.design = _design if _design
    end
    _design
  end

  def design=(design)
    self.design_id = design.id.to_s
    save
  end

  ##
  # Return the set home page.
  def page
    Page.by_slug(page_id) if page_id
  end

  def page=(page)
    self.page_id = page.slug
    save
  end

  def unset_page(page)
    if page_id == page.slug
      self.page_id = nil
      save
    end
  end

end
