class User
  include MongoODM::Document
  include MongoODM::Document::Timestamps

  ##
  # Attributes
  field :name
  field :login
  field :passwd
  field :salt
  field :login_at, Time

  ##
  # Virtual Attributes
  attr_accessor :password, :password_confirmation

  ##
  # Indexes
  create_index :login, :unique => true

  ##
  # Validations
  validates_presence_of :login, :name
  validates_presence_of :password, :if => :password_required?
  validates_length_of :password, :minimum => 5, :if => :password_required?
  validates_confirmation_of :password, :if => :password_required?

  ##
  # Callbacks
  before_save :encrypt_password

  ##
  # Finder
  def self.by_id(id)
    find_one(:_id => BSON::ObjectId(id.to_s))
  end

  def self.by_login(login)
    find_one(:login => login)
  end

  def self.sort_logins
    find({}, {:sort => [:login_at, :desc]})
  end

  ##
  # Create default user
  def self.create_default
    return false unless count == 0
    user = new(:login => 'admin', :name => 'admin')
    user.password, user.password_confirmation = 'admin', 'admin'
    user.save && user
  end

  ##
  # Authenticate user
  def self.authenticate(login, password)
    return false if login.empty?
    return false unless user = User.by_login(login)
    Encrypt.compare(password,user.salt,user.passwd) ? user : false
  end

  ##
  # Set last login time
  def record_login
    self.login_at = Time.now.utc
    save
  end

  protected
  def password_required?
    passwd.empty? || !password.empty?
  end

  def encrypt_password
    unless password.empty?
      self.salt = Encrypt.random_hash
      self.passwd = Encrypt.encrypt(password,salt)
      self.password = nil
    end
  end

end
