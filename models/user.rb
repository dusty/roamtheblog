class User < Mongomatic::Base
  include Roam::Models

  def self.create_indexes
    collection.create_index :login, :unique => true
  end

  def self.by_id(id)
    find_one(:_id => BSON::ObjectId(id.to_s))
  end

  def self.by_login(login)
    find_one(:login => login)
  end

  def self.sort_logins
    find({}, {:sort => [:login_at, :desc]})
  end

  def self.create_default
    return false unless count == 0
    user = new(:login => 'admin', :name => 'admin')
    user.password, user.password_confirmation = 'admin', 'admin'
    user.insert && user
  end

  def self.authenticate(login, password)
    return false if login.empty?
    return false unless user = User.by_login(login)
    Encrypt.compare(password,user.salt,user.passwd) ? user : false
  end

  matic_accessor :name, :login, :passwd, :salt, :login_at
  attr_accessor :password, :password_confirmation

  def validate
    %w{ login name }.each do |attr|
      errors.add(attr, 'is required') if self[attr].blank?
    end
    if password_required?
      errors.add(:password, 'must be > 5 char') unless (password && password.length > 4)
      errors.add(:password, 'does not match') unless password == password_confirmation
    end
  end

  def before_insert_or_update
    encrypt_password
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
