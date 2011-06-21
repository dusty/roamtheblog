class Page < Mongomatic::Base
  include Roam::Models

  matic_accessor :title, :body, :slug

  def validate
    %w{ title body }.each do |attr|
      errors.add(attr, 'is required') if send(attr).blank?
    end
  end

  def before_insert_or_update
    generate_slug
  end

  def self.create_indexes
    collection.create_index :slug, :unique => true
  end

  def self.by_slug(slug)
    find_one(:slug => slug)
  end

  def self.sort_updated
    find({}, {:sort => [:updated_at, :desc]})
  end

  def html
    RedCloth.new(body).to_html
  end

  protected

  def generate_slug
    (self.slug = title.slugize) if slug.empty?
  end

end
