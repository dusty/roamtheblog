class Comment
  include MongoMapper::EmbeddedDocument
  include MongoMapper::Plugins::Timestamps

  key :name
  key :email
  key :comment
  key :url
  key :created_at
  key :ip
  timestamps!

  validates_presence_of :name
  validates_format_of :email, :with => Validator.email
  validates_length_of :comment, :within => 3..254
  validates_format_of :url, :allow_blank => true, :with =>
    /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix

end