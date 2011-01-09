class Site < Mongomatic::Base

  ##
  # :title, :domain, :location, :timezone, :cache, :design, :settings
  
  def self.create_default
    return false unless empty?
    new.insert
  end
  
  ##
  # Callbacks
  def before_insert_or_update
    setup_defaults
    normalize_attributes
  end
  
  ##
  # Relationships
  def design
    @design ||= begin
      Design.find_one(:_id => self['design']) unless self['design'].blank?
    end
  end
  
  def design=(design)
    return false unless design.is_a?(Design)
    self['design'] = design['_id']
    self.update
  end
  
  private
  def setup_defaults
    self['title']    ||= 'My New Blog'
    self['domain']   ||= 'example.com'
    self['timezone'] ||= 'UTC'
    self['cache']    ||= 300
    self['settings'] ||= {}
  end
  
  def normalize_attributes
    [:title, :domain, :location, :timezone].each do |attribute|
      blank_attribute(attribute)
    end
    self['cache'] = self['cache'].to_i
    self['cache'] = nil unless self['cache'] > 0
  end
  
  def blank_attribute(attribute)
    self[attribute] = nil if self[attribute].empty?
  end

end
