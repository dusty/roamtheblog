class Post < Roam::Model

  def self.create_indexes
    collection.create_index [[:slug,1],[:published_at,1]], :unique => true
    collection.create_index :tags
  end

  def self.by_slug(slug)
    find_one(:slug => slug)
  end

  def self.by_tag(tag)
    find(:tags => tag)
  end

  def self.sort_published
    sort([:published_at, :desc])
  end

  def self.sort_updated
    sort([:updated_at, :desc])
  end

  def self.recent_update
    sort_updated.first.updated_at
  end

  def self.recent(limit=0)
    active.sort_published.limit(limit.to_i)
  end

  def self.without(post)
    find(:_id => {'$ne' => post.id})
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

  ##
  # Posts that are active and younger than a certain time
  def self.younger(time)
    time = time.utc
    now  = Time.now.utc
    find(:published_at => {'$gt' => time, '$lt' => now}).sort([:published_at, :asc])
  end

  ##
  # Posts that are active and older than a certain time
  def self.older(time)
    now  = Time.now.utc
    time = time.utc
    max_age = (time > now) ? now : time
    find(:published_at => {'$lt' => max_age}).sort([:published_at, :desc])
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

    young = without(post).younger(post.published_at).limit(limit*2).to_a
    older = without(post).older(post.published_at).limit(limit*2).to_a

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

  def tags
    self[:tags].to_a
  end

  def validate
    %w{ title author body}.each do |attr|
      errors.add(attr, 'is required') if self[attr].blank?
    end
  end

  def before_insert_or_update
    generate_slug
  end

  def tags=(list)
    list = list.split(%r{,\s*}).uniq if list.is_a?(String)
    write_attribute(:tags, list)
  end

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
