class User
  include MongoMapper::Document

  key :name, String
  key :login, String
  key :passwd, String
  key :salt, String
  key :login_at, Time
  timestamps!

  attr_accessor :password, :password_confirmation

  ensure_index :login, :unique => true

  validates_presence_of :login, :name
  validates_presence_of :password, :if => :password_required?
  validates_length_of :password, :minimum => 5, :if => :password_required?
  validates_confirmation_of :password, :if => :password_required?

  before_save :encrypt_password

  def self.by_login(login)
    first(:login => login)
  end

  def self.recent(limit=0)
    sort([:login_at, :desc]).limit(limit.to_i)
  end

  def self.create_default
    return false unless count == 0
    user = new(:login => 'admin', :name => 'admin')
    user.password, user.password_confirmation = 'admin', 'admin'
    user.save && user
  end

  def self.authenticate(login, password)
    return false if login.empty?
    return false unless user = User.by_login(login)
    Encrypt.compare(password,user.salt,user.passwd) ? user : false
  end

  def record_login
    update_attributes(:login_at => Time.now.utc)
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
