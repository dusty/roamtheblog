class Design
  include MongoODM::Document
  include MongoODM::Document::Timestamps

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
  # Duplicate a design
  def self.duplicate(id)
    return false unless original = by_id(id)
    attributes = original.attributes
    attributes.delete('_id')
    attributes.delete('created_at')
    attributes.delete('updated_at')
    copy = new(attributes)
    tag = "#{Time.now.to_i}"
    copy.name = "#{original.name}-#{tag}"
    copy.description = "#{tag}: #{original.description}"
    copy
  end

  ##
  # Validations
  validates_presence_of :name, :layout, :blog, :feed, :home, :page, :post
  validates_presence_of :error, :missing, :style, :script

  ##
  # Default design
  def self.create_default
    return false unless count == 0
    design = new
    design.name = 'RoamTheBlog'
    design.description = 'Clean design inspired by roamthepla.net'
    Dir["apps/user/templates/*.mustache"].each do |template|
      attribute = File.basename(template, File.extname(template))
      design.send("#{attribute}=", File.read(template))
    end
    design.save && design
  end

  ##
  # Finders
  def self.by_id(id)
    find_one(:_id => BSON::ObjectId(id.to_s))
  end

  def self.sort_updated
    find({}, {:sort => [:updated_at, :desc]})
  end

  ##
  # Activate the design
  def activate
    Site.default.design = self
  end

  ##
  # Is the design active
  def active?
    Site.default.design == self
  end

end
