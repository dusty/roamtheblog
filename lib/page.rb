class Page < Mongomatic::Base

  ##
  # :title, :body, :slug
  
  ##
  # Indexes
  def self.create_indexes
    collection.create_index('slug', :unique => true)
  end
  
  ##
  # Finders
  def self.slug(slug)
    find_one(:slug => slug)
  end
  
  ##
  # Validations
  def validate
    self.errors.add("title","required") if self['title'].empty?
    self.errors.add("body","required")  if self['body'].empty?      
  end
  
  ##
  # Callbacks
  def before_validate
    generate_slug
  end
  
  def before_insert_or_update
    self['updated'] = Time.now.utc
  end

  # Convert body to html
  def html
    RedCloth.new(self['body'].force_encoding('ISO-8859-1')).to_html
  end
  
  protected
  # Generate a URL friendly slug
  def generate_slug
    (self['slug'] = self['title'].slugize) if self['slug'].empty?
  end
  
end
