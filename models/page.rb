class Page
  include MongoMapper::Document

  key :title, String
  key :body, String
  key :slug, String
  timestamps!

  validates_presence_of :title, :body, :slug

  before_save :generate_slug

  def self.create_indexes
    collection.create_index :slug, :unique => true
  end

  def self.by_slug(slug)
    first(:slug => slug)
  end

  def self.sort_updated
    sort(:updated_at.desc)
  end

  def html
    RedCloth.new(body).to_html
  end

  protected

  def generate_slug
    (self.slug = title.slugize) if slug.empty?
  end

end
