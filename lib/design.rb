class Design < Mongomatic::Base

  ##
  # :name, :description
  # :layout, :blog, :feed, :home, :page, :post
  # :style, script, :error, :missing
  
  ##
  # Finder
  def self.id(id)
    id = BSON::ObjectId(id) unless id.is_a?(BSON::ObjectId)
    find_one(id)
  end
  
  ##
  # Duplicate a design
  def self.copy(id)
    return false unless original = id(id)
    copy = new(original.doc)
    copy.doc.delete('_id')
    tag = "#{Time.now.to_i}"
    copy["name"] = "#{original['name']}-#{tag}"
    copy["description"] = "#{tag}: #{original['description']}"
    copy
  end
  
  ##
  # Validations
  def validate
    %w{
      name layout blog feed home page post error missing style
    }.each {|field| require_field(field)}
  end
  
  ##
  # Callbacks
  def before_insert_or_update
    setup_defaults
  end
  
  ##
  # Setup defaults
  def setup_defaults  
    self['script'] = "" if self['script'].nil?
    self['description'] = "" if self['description'].nil?
  end
  
  ##
  # Default design
  def self.create_default
    return false unless empty?
    design = new
    design['name'] = 'RoamTheBlog'
    design['description'] = 'Clean design inspired by roamthepla.net'
    Dir["apps/user/templates/*.mustache"].each do |template|
      attribute = File.basename(template, File.extname(template))
      design[attribute] = File.read(template)
    end
    design.insert && Site.first.design = design
  end
  
  ##
  # Activate a design if needed
  def self.activate_design
    Site.first.design ||= Design.first
  end
  
  ##
  # Is the design active
  def active?
  end
  
  ##
  # Delete the design
  # Recreate default if needed
  # Mark a design as active if needed
  def delete
    remove!(:raise => true)
    Design.create_default
    Design.activate_design
  end
  
  protected
  # Make sure a field isn't blank
  def require_field(field)
    self.errors.add(field,"required") if self[field].empty?
  end
  
end
