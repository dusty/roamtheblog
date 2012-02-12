class Page
  include MongoMapper::Document

  key :title, String
  key :body, String
  key :slug, String
  timestamps!

  ensure_index :slug, :unique => true

  validates_presence_of :title, :body

  before_validation :normalize_slug
  before_save :generate_slug

  def self.by_slug(slug)
    first(:slug => slug)
  end

  def self.recent(limit=0)
    sort([:updated_at, :desc]).limit(limit.to_i)
  end

  def html
    RedCloth.new(body).to_html
  end

  protected

  def normalize_slug
    self.slug = slug.gsub(/^\//, '').slugize unless slug.empty?
  end

  def generate_slug
    (self.slug = title.slugize) if slug.empty?
  end

end
