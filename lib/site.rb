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
  
  ##
  def design
    super ||= Design.create_default
  end
  
  def self.create_default
    return false unless empty?
    _new = new
    _new.settings['primary_color'] = '#295187'
    _new.save
  end

end
