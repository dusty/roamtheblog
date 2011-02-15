class Post
  include Mongoid::Document
  include Mongoid::Timestamps

  ##
  # Attributes
  field :title
  field :body
  field :author
  field :slug
  field :published_at, :type => Time
  field :tags, :type => Array, :default => []
  
  ##
  # Indexes
  index([[:slug,Mongo::ASCENDING],[:published_at,Mongo::ASCENDING]],:unique => true)
  index :tags
  
  ##
  # Validations
  validates_presence_of :title, :author, :body
  
  ##
  # Callbacks
  before_validation :generate_slug
  
  ##
  # Finders
  def self.recent
    order_by(:published_at.desc)
  end
  
  def self.recent_update
    recent.first.updated_at
  end
  
  def self.by_slug(slug)
    where(:slug => slug).first
  end

  def self.by_tag(tag)
    recent.where(:tags => tag)
  end
  
  def self.nodate
    recent.where(:date => nil)
  end
  
  def self.active
    recent.where(:date.lte => Time.now.utc)
  end
  
  def self.future
    recent.where(:date.gt => Time.now.utc)
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
    date = publish.is_a?(String) ? Chronic.parse(publish) : publish
    write_attribute(:published_at, date)
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