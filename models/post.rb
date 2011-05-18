class Post < Roam::Model

  def self.create_indexes
    collection.create_index [[:slug,1],[:published_at,1]], :unique => true
    collection.create_index :tags
  end

  def self.by_slug(slug)
    find_one(:slug => slug)
  end

  def self.sort_published
    find({}, {:sort => [:published_at, :desc]})
  end

  def self.sort_updated
    find({}, {:sort => [:updated_at, :desc]})
  end

  def self.recent_update
    sort_updated.limit(1).first.updated_at
  end

  def self.recent(limit=0)
    active.limit(limit.to_i)
  end

  def self.nodate(tag=nil)
    criteria = {:published_at => nil}
    criteria.update(:tags => tag) if tag
    find(criteria).sort([:updated_at, :desc])
  end

  def self.active(tag=nil)
    criteria = {:published_at => {'$lte' => Time.now.utc}}
    criteria.update(:tags => tag) if tag
    find(criteria).sort([:published_at, :desc])
  end

  def self.future(tag=nil)
    criteria = {:published_at => {'$gt' => Time.now.utc}}
    criteria.update(:tags => tag) if tag
    find(criteria).sort([:published_at, :desc])
  end

  ##
  # Posts that are active and younger than a certain time
  def self.younger(post,limit)
    time     = post.published_at.utc
    now      = Time.now.utc
    criteria = {:published_at => {'$gt' => time, '$lt' => now}, :_id => {'$ne' => post.id}}
    find(criteria).sort([:published_at, :asc]).limit(limit.to_i)
  end

  ##
  # Posts that are active and older than a certain time
  def self.older(post,limit)
    now      = Time.now.utc
    time     = post.published_at.utc
    max_age  = (time > now) ? now : time
    criteria = {:published_at => {'$lt' => max_age}, :_id => {'$ne' => post.id}}
    find(criteria).sort([:published_at, :desc]).limit(limit.to_i)
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

  matic_accessor :title, :body, :author, :slug, :published_at, :tags

  def validate
    %w{ title author body}.each do |attr|
      errors.add(attr, 'is required') if self[attr].blank?
    end
  end

  def before_insert_or_update
    split_tags
    generate_slug
    parse_published
  end

  def tags
    self[:tags].to_a
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
    list = self[:tags].split(%r{,\s*}).uniq if self[:tags].is_a?(String)
    self[:tags] = list
  end

  def generate_slug
    return nil if title.empty?
    date = published_at.is_a?(Time) ? published_at : Time.now.in_time_zone
    prefix = date.strftime("%Y%m%d")
    self.slug = "#{prefix}-#{title.slugize}"
  end

  def parse_published
    publish = Chronic.parse(self[:published_at]) if self[:published_at].is_a?(String)
    self[:published_at] = publish.is_a?(Time) ? publish.utc : nil
  end

end
