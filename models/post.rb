class Post
  include MongoMapper::Document

  key :title, String
  key :body, String
  key :author, String
  key :slug, String
  key :published_at, Time
  key :tags, Array, :default => lambda { Array.new }
  key :location, String
  timestamps!

  attr_accessor :published_string, :tags_string

  validates_presence_of :title, :body, :author

  before_save :split_tags, :parse_published, :generate_slug

  def self.create_indexes
    collection.create_index [[:slug,1],[:published_at,1]], :unique => true
    collection.create_index :tags
  end

  def self.by_slug(slug)
    first(:slug => slug)
  end

  def self.sort_published
    sort(:published_at.desc)
  end

  def self.sort_updated
    sort(:updated_at.desc)
  end

  def self.recent_update
    sort_updated.limit(1).first.updated_at
  end

  def self.recent(limit=0)
    active.limit(limit.to_i)
  end

  def self.nodate(tag=nil)
    criteria = where(:published_at => nil)
    criteria = criteria.where(:tags => tag) if tag
    criteria.sort(:updated_at.desc)
  end

  def self.active(tag=nil)
    criteria = where(:published_at.lte => Time.now.utc)
    criteria = criteria.where(:tags => tag) if tag
    criteria.sort(:published_at.desc)
  end

  def self.future(tag=nil)
    criteria = where(:published_at.gt => Time.now.utc)
    criteria = criteria.where(:tags => tag) if tag
    criteria.sort(:published_at.desc)
  end

  ##
  # Posts that are active and younger than a certain time
  def self.younger(post,limit)
    time     = post.published_at.utc
    now      = Time.now.utc
    criteria = where(:published_at => {:$gt => time, :$lt => now}).where(:_id.ne => post.id)
    criteria.sort(:published_at.asc).limit(limit.to_i)
  end

  ##
  # Posts that are active and older than a certain time
  def self.older(post,limit)
    now      = Time.now.utc
    time     = post.published_at.utc
    max_age  = (time > now) ? now : time
    criteria = where(:published_at.lt => max_age).where(:_id.ne => post.id)
    criteria.sort(:published_at.desc).limit(limit.to_i)
  end

  ##
  # Find posts near a post.
  # Return a Hash with :younger and :older keys.
  #
  # Will return the limit on both sides of the post.  However, if one
  # side is lower than the other (perhaps the first/last post), then
  # the other side is adjusted.
  #
  # Start with limit*2 on the queries in case we need to fill the entire
  # other side.
  #
  # Post.near(somepost,3)
  # {:younger => [post1, post2], :older => [post3, post4, post5, post6]}
  def self.near(post,limit=2)
    return {:younger => [], :older => []} unless post.published_at

    young = younger(post,limit*2).to_a
    older = older(post,limit*2).to_a

    older_diff = (older.length < limit) ? (limit - older.length) : 0
    young_diff = (young.length < limit) ? (limit - young.length) : 0
    older_len  = limit + young_diff - 1
    young_len  = limit + older_diff - 1

    {:younger => young[0..young_len].reverse, :older => older[0..older_len]}
  end

  def self.tags
    collection.distinct(:tags, {:published_at => {'$lte' => Time.now.utc}})
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

  def split_tags
    return [] if tags_string.empty?
    self.tags = tags_string.split(%r{,\s*}).uniq
  end

  def generate_slug
    return nil if title.empty?
    date = published_at.is_a?(Time) ? published_at : Time.now.in_time_zone
    prefix = date.strftime("%Y%m%d")
    self.slug = "#{prefix}-#{title.slugize}"
  end

  def parse_published
    return nil if published_string.empty?
    self.published_at = Chronic.parse(published_string).utc rescue nil
  end

end
