class Page
  include MongoODM::Document
  include MongoODM::Document::Timestamps

  ##
  # Attributes
  field :title
  field :body
  field :slug

  ##
  # Indexes
  create_index :slug, :unique => true

  ##
  # Validations
  validates_presence_of :title, :body

  ##
  # Callbacks
  before_save :generate_slug

  ##
  # Finders
  def self.by_slug(slug)
    find_one(:slug => slug)
  end

  def self.sort_updated
    find({}, {:sort => [:updated_at, :desc]})
  end

  # Convert body to html
  def html
    RedCloth.new(body).to_html
  end

  protected
  # Generate a URL friendly slug
  def generate_slug
    (self.slug = title.slugize) if slug.empty?
  end

end
