class User
  include MongoMapper::Document

  key :name, String
  key :login, String
  key :passwd, String
  key :salt, String
  key :login_at, Time
  timestamps!
  attr_accessor :password, :password_confirmation

  before_save :encrypt_password

  validates_presence_of :name, :login
  validates_length_of :password, :minimum => 5, :if => :password_required?
  validates_confirmation_of :password, :if => :password_required?

   def validate
     %w{ login name }.each do |attr|
       errors.add(attr, 'is required') if send(attr).blank?
     end
     if password_required?
       errors.add(:password, 'must be > 5 char') unless (password && password.length > 4)
       errors.add(:password, 'does not match') unless password == password_confirmation
     end
   end

  def self.create_indexes
    collection.create_index :login, :unique => true
  end

  def self.by_id(id)
    find(id)
  end

  def self.by_login(login)
    first(:login => login)
  end

  def self.sort_logins
    sort(:login_at.desc)
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
    self.login_at = Time.now.utc
    update
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
