class Site
  include Mongoid::Document
  include Mongoid::Timestamps

  ##
  # Attributes
  field :location
  field :title, :default => 'My New Blog'
  field :domain, :default => 'example.com'
  field :timezone, :default => 'UTC'
  field :cache, :type => Integer, :default => 300
  field :settings, :type => Hash, :default => {}
  
  ##
  # Relationships
  references_one :design
  
  def self.create_default
    return false unless criteria.empty?
    _new = new
    _new.settings['primary_color'] = '#295187'
    _new.save! && _new
  end
  
  def activate_design(design)
    self.design = design
    self.save!
  end
  
  def active_design
    self.design ||= (Design.first || Design.create_default)
  end
  


end
