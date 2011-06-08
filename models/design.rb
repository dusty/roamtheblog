class Design < Mongomatic::Base
  include Roam::Models

  def self.duplicate(id)
    return false unless original = by_id(id)
    attributes = original.doc
    attributes.delete('_id')
    attributes.delete('created_at')
    attributes.delete('updated_at')
    copy = new(attributes)
    tag = "#{Time.now.to_i}"
    copy.name = "#{original.name}-#{tag}"
    copy.description = "#{tag}: #{original.description}"
    copy
  end

  def self.create_default
    return false unless count == 0
    design = new
    design.name = 'RoamTheBlog'
    design.description = 'Clean design inspired by roamthepla.net'
    Dir["templates/user/*.mustache"].each do |template|
      attribute = File.basename(template, File.extname(template))
      design.send("#{attribute}=", File.read(template))
    end
    design.insert && design
  end

  def self.by_id(id)
    find_one(:_id => BSON::ObjectId(id.to_s))
  end

  def self.sort_updated
    find({}, {:sort => [:updated_at, :desc]})
  end

  matic_accessor :name, :description, :layout, :blog, :feed, :home
  matic_accessor :page, :post, :style, :script, :error, :missing

  def validate
    %w{name layout blog feed home page post error missing style script}.each do |attr|
      errors.add(attr, 'is required') if send(attr).blank?
    end
  end

  def activate
    Site.default.design = self
  end

  def active?
    Site.default.design == self
  end

end
