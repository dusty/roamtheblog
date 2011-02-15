class User
  include Mongoid::Document
  include Mongoid::Timestamps

  ##
  # Attributes
  field :name
  field :login
  field :passwd
  field :salt

  ##
  # Virtual Attributes
  attr_accessor :password, :password_confirmation
  
  ##
  # Indexes
  index :login, :unique => true
  
  ##
  # Validations
  validates_presence_of :login, :name
  validates_presence_of :password, :if => :password_required?
  validates_length_of :password, :if => :password_required?
  validates_confirmation_of :password, :if => :password_required?
  
  ##
  # Callbacks
  before_save :encrypt_password
  
  ##
  # Finder
  def self.id(id)
    criteria.id(id)
  end
  
  ##
  # Create default user
  def self.create_default
    return false unless empty?
    user = new(:login => 'admin', :name => 'admin')
    user.password, user.password_confirmation = 'admin', 'admin'
    user.save!
  end
 
  ##
  # Delete
  def delete(user)
    raise(StandardError, "Cannot delete yourself") if user == self
    raise(StandardError, "Cannot delete only user") if User.count < 2
    self.destroy!
  end
  
  def self.authenticate(login, password)
    return false if login.empty?
    return false unless user = User.where(:login => login).first
    Encrypt.compare(password,user.salt,user.passwd) ? user : false
  end
  
  def password_required?
    self.passwd.empty? || !self.password.empty?
  end
  
  protected
  def encrypt_password
    unless password.empty?
      self.salt = Encrypt.random_hash
      self.passwd = Encrypt.encrypt(password,self.salt)
      self.password = nil
    end
  end
  
end