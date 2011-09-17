class Post
  include MongoMapper::Document

  key :title, String
  key :body, String
  key :author, String
  key :slug, String
  key :published_at, Time
  key :tags, Array
  key :location, String
  timestamps!

  ensure_index [[:slug,1],[:published_at,1]], :unique => true
  ensure_index :tags

  validates_presence_of :title, :author, :body

  before_save :generate_slug

  def self.by_slug(slug)
    first(:slug => slug)
  end

  def self.recent_update
    sort([:updated_at, :desc]).limit(1).first.updated_at
  end

  def self.recent(limit=0)
    active.limit(limit.to_i)
  end

  def self.nodate(tag=nil)
    criteria = {:published_at => nil}
    criteria.update(:tags => tag) if tag
    where(criteria).sort([:updated_at, :desc])
  end

  def self.active(tag=nil)
    criteria = {:published_at => {'$lte' => Time.now.utc}}
    criteria.update(:tags => tag) if tag
    where(criteria).sort([:published_at, :desc])
  end

  def self.future(tag=nil)
    criteria = {:published_at => {'$gt' => Time.now.utc}}
    criteria.update(:tags => tag) if tag
    where(criteria).sort([:published_at, :desc])
  end

  ##
  # Posts that are active and younger than a certain time
  def self.younger(post,limit)
    time     = post.published_at.utc
    now      = Time.now.utc
    criteria = {:published_at => {'$gt' => time, '$lt' => now}, :_id => {'$ne' => post.id}}
    where(criteria).sort([:published_at, :asc]).limit(limit.to_i)
  end

  ##
  # Posts that are active and older than a certain time
  def self.older(post,limit)
    now      = Time.now.utc
    time     = post.published_at.utc
    max_age  = (time > now) ? now : time
    criteria = {:published_at => {'$lt' => max_age}, :_id => {'$ne' => post.id}}
    where(criteria).sort([:published_at, :desc]).limit(limit.to_i)
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

    young = younger(post,limit*2).all
    older = older(post,limit*2).all

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

  def update_from_params(params={})
    self.title        = params[:title]
    self.body         = params[:body]
    self.author       = params[:author]
    self.location     = params[:location]
    self.tags         = parse_tags(params[:tags])
    self.published_at = parse_published(params[:published_at])
  end

  def save_without_timestamps
    begin
      self.class.skip_callback(:save, :update_timestamps)
      save
    ensure
      self.class.set_callback(:save, :update_timestamps)
    end
  end

  protected

  def generate_slug
    return nil if title.empty?
    date = published_at.is_a?(Time) ? published_at : Time.now.in_time_zone
    prefix = date.strftime("%Y%m%d")
    self.slug = "#{prefix}-#{title.slugize}"
  end

  def parse_tags(tags)
    tags.is_a?(String) ? tags.split(%r{,\s*}).uniq : tags
  end

  def parse_published(published)
    (published.is_a?(String) ? Chronic.parse(published).utc : published.utc) rescue nil
  end

end
