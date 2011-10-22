class Design
  include MongoMapper::Document

  key :name, String
  key :description, String
  key :layout, String
  key :blog, String
  key :feed, String
  key :home, String
  key :page, String
  key :post, String
  key :style, String
  key :script, String
  key :error, String
  key :missing, String
  timestamps!

  validates_presence_of :name, :layout, :blog, :feed, :home, :page, :post
  validates_presence_of :error, :missing, :style, :script

  def self.duplicate(id)
    return false unless original = find(id)
    tag = "#{Time.now.to_i}"
    copy = original.clone
    copy.name = "#{original.name}-#{tag}"
    copy.description = "#{tag}: #{original.description}"
    copy
  end

  def self.create_default
    return false unless count == 0
    design = new
    design.name = 'CleanBlog'
    design.description = 'Clean with lots of whitespace'
    Dir["templates/cleanwhite/*.mustache"].each do |template|
      attribute = File.basename(template, File.extname(template))
      design.send("#{attribute}=", File.read(template))
    end
    design.save && design
  end

  def self.recent(limit=0)
    sort([:updated_at, :desc]).limit(limit.to_i)
  end

  def activate
    Site.default.design = self
  end

  def active?
    Site.default.design == self
  end

end
