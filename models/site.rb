class Site < Roam::Model

  matic_accessor :location, :title, :domain, :timezone, :cache, :settings, :design_id

  def self.create_default
    return false unless count == 0
    site = new
    site.settings = {}
    site.settings['primary_color'] = '#295187'
    site.insert && site
  end

  def self.default
    find_one
  end

  def before_insert_or_update
    set_defaults
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
    update
  end

  protected

  def set_defaults
    self.title ||= 'My New Blog'
    self.domain ||= 'example.com'
    self.timezone ||= 'UTC'
    self.cache ||= 300
    self.settings ||= {}
  end

end
