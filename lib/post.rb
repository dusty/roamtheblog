class Post
  include Mongoid::Document
  include Mongoid::Timestamps

  ##
  # Attributes
  field :slug
  field :publish_at, :type => Time
  field :tags, :type => Array, :default => []
  
  ##
  # Indexes
  index([[:slug,Mongo::ASCENDING],[:publish_at,Mongo::ASCENDING]],:unique => true)
  index :tags
  
  ##
  # Validations
  validates_presence_of :title, :author, :body
  
  ##
  # Callbacks
  before_validation :generate_date, :generate_slug
  
  ##
  # Finders
  def self.recent
    order_by(:publish_at.desc)
  end
  
  def self.slug(slug)
    where(:slug => slug).first
  end

  def self.tag(tag)
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
    self.tags = list.is_a?(String) ? list.split(%r{,\s*}).uniq : list
  end
  
  def html
    RedCloth.new(self.body).to_html
  end
  
  def excerpt
    HTML_Truncator.truncate(html, 15)
  end
  
  def active?
    self.publish_at ? (Time.now.utc >= self.publish_at) : false
  end

  protected
  def parse_date(date)
    return nil if date.blank?
    date = Chronic.parse(date) if date.is_a?(String)
    date ? date.utc : nil
  end
  
  def generate_date
    self.date = parse_date(self.date) if self.date.is_a?(String)
  end

  def generate_slug
    return false if self.title.empty?
    date = self.date.is_a?(Time) ? self.date : Time.now.in_time_zone
    prefix = date.strftime("%Y%m%d")
    self.slug = "#{prefix}-#{self.title.slugize}"
  end
  
end