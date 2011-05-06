class Site
  include MongoODM::Document
  include MongoODM::Document::Timestamps

  ##
  # Attributes
  field :location
  field :title, String, :default => 'My New Blog'
  field :domain,  String, :default => 'example.com'
  field :timezone,  String, :default => 'UTC'
  field :cache, Integer, :default => 300
  field :settings, Hash, :default => {}
  field :design_id, String

  def self.create_default
    return false unless count == 0
    site = new
    site.settings['primary_color'] = '#295187'
    site.save && site
  end

  def self.default
    find_one
  end

  ##
  # Return the associated design if it exists
  # If not assign the next design or create a default
  def design
    unless design_id && _design = Design.by_id(design_id)
      _design = Design.find_one || Design.create_default
      self.design = _design if _design
    end
    _design
  end

  def design=(design)
    self.design_id = design.id.to_s
    save
  end

end
