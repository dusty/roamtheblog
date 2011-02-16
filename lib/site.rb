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
    _new = new
    _new.settings['primary_color'] = '#295187'
    _new.save && _new
  end
  
  def self.default
    find_one
  end
  
  def design
    Design.find_one(:_id => design_id)
  end
  
  def design=(design)
    self.design_id = design.id
  end
  
  def activate_design(design)
    self.design = design
    self.save
  end
  
  def active_design
    self.design ||= (Design.find_one || Design.create_default)
  end
  


end
