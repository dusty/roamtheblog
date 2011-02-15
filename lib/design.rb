class Design
  include Mongoid::Document
  include Mongoid::Timestamps
  
  ##
  # Attributes
  field :name
  field :description
  field :layout
  field :blog
  field :feed
  field :home
  field :page
  field :post
  field :style
  field :script
  field :error
  field :missing
  
  ##
  # Finder
  def self.id(id)
    criteria.id(id)
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
  validates_presence_of :name, :layout, :blog, :feed, :home, :page, :post
  validates_presence_of :error, :missing, :style, :script
  
  ##
  # Default design
  def self.create_default
    return false unless empty?
    design = new
    design.name = 'RoamTheBlog'
    design.description = 'Clean design inspired by roamthepla.net'
    Dir["apps/user/templates/*.mustache"].each do |template|
      attribute = File.basename(template, File.extname(template))
      design.send("#{attribute}=", File.read(template))
    end
    design.save && Site.first.design = design
  end
  
  ##
  # Activate a design if needed
  def self.activate_design
    Site.first.design ||= Design.first
  end
  
  ##
  # Is the design active
  def active?
    Site.first.design == self
  end
  
  ##
  # Delete the design
  # Recreate default if needed
  # Mark a design as active if needed
  def remove
    self.destroy
    Design.create_default
    Design.activate_design
  end
  
end
