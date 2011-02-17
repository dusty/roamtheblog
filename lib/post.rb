class Post
  include MongoODM::Document
  include MongoODM::Document::Timestamps

  ##
  # Attributes
  field :title
  field :body
  field :author
  field :slug
  field :published_at, Time
  field :tags, Array, :default => []
  
  ##
  # Indexes
  create_index [[:slug,Mongo::ASCENDING],[:published_at,Mongo::ASCENDING]],
    :unique => true
  create_index :tags
  
  ##
  # Validations
  validates_presence_of :title, :author, :body
  
  ##
  # Callbacks
  before_save :generate_slug
  
  ##
  # Finders
  def self.by_slug(slug)
    find_one(:slug => slug)
  end

  def self.by_tag(tag)
    find(:tags => tag)
  end
  
  def self.sort_published
    find({}, {:sort => [:published_at, :desc]})
  end
  
  def self.sort_updated
    find({}, {:sort => [:updated_at, :desc]})
  end
  
  def self.recent_update
    sort_updated.find_one.updated_at rescue nil
  end
  
  def self.recent(limit=nil)
    limit ? active.sort_published.limit(limit) : active.sort_published
  end
  
  def self.nodate
    find(:published_at => nil).sort_updated
  end
  
  def self.active
    find(:published_at => {'$lte' => Time.now.utc}).sort_published
  end
  
  def self.future
    find(:published_at => {'$gt' => Time.now.utc}).sort_published
  end
  
  def self.tags
    collection.distinct(:tags)
  end
  
  ##
  # Add comma seperated list of tags
  def tags=(list)
    list = list.split(%r{,\s*}).uniq if list.is_a?(String)
    write_attribute(:tags, list)
  end
  
  ##
  # Parse a string for published_at
  def published_at=(publish)
    publish = Chronic.parse(publish) if publish.is_a?(String)
    write_attribute(:published_at, publish.utc) if publish.is_a?(Time)
  end
  
  def html
    RedCloth.new(body).to_html
  end
  
  def excerpt
    HTML_Truncator.truncate(html, 15)
  end
  
  def active?
    published_at ? (Time.now.utc >= published_at) : false
  end

  protected
  def generate_slug
    return nil if title.empty?
    date = published_at.is_a?(Time) ? published_at : Time.now.in_time_zone
    prefix = date.strftime("%Y%m%d")
    self.slug = "#{prefix}-#{title.slugize}"
  end
  
end