class Site
  include MongoMapper::Document

  key :location, String
  key :title, String, :default => 'My New Blog'
  key :domain, String, :default => 'example.com'
  key :timezone, String, :default => 'UTC'
  key :cache, Integer, :default => 300
  key :settings, Hash
  key :design_id, BSON::ObjectId
  key :page_id, BSON::ObjectId

  def self.create_default
    return false unless count == 0
    site = new
    site.settings['primary_color'] = '#295187'
    site.save && site
  end

  def self.default
    first
  end

  ## Return the associated design if it exists
  ## If not assign the next design or create a default
  def design
    unless design_id && _design = Design.find(design_id)
      _design = (Design.first || Design.create_default)
      self.design = _design
    end
    _design
  end

  def design=(design)
    update_attributes(:design_id => design.id)
  end

  ## Return the set home page.
  def page
    Page.find(page_id) if page_id
  end

  def page=(page)
    update_attributes(:page_id => page.id)
  end

  def unset_page(page)
    update_attributes(:page_id => nil) if (page_id == page.id)
  end

end
