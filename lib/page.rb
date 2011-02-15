class Page
  include Mongoid::Document
  include Mongoid::Timestamps
  
  ##
  # Attributes
  field :title
  field :body
  field :slug
  
  ##
  # Indexes
  index :slug, :unique => true
  
  ##
  # Validations
  validates_presence_of :title, :body
  
  ##
  # Finders
  def self.by_slug(slug)
    where(:slug => slug).first
  end
  
  ##
  # Callbacks
  before_validation :generate_slug

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
