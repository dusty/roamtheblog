class User < Mongomatic::Base

  ##
  # :name, :login, :passwd, :salt

  ##
  # Indexes
  def self.create_indexes
    collection.create_index(:login, :unique => true)
  end
  
  ##
  # Finder
  def self.id(id)
    id = BSON::ObjectId(id) unless id.is_a?(BSON::ObjectId)
    find_one(id)
  end
  
  ##
  # Create default user
  def self.create_default
    return false unless empty?
    user = new(:login => 'admin', :name => 'admin')
    user.password, user.password_confirmation = 'admin', 'admin'
    user.insert!(:raise => true)
  end
  
  ##
  # Validations
  def validate
    self.errors.add("login","required") if self['login'].empty?
    self.errors.add("name","required")  if self['name'].empty?
    if password_required? 
      self.errors.add("password","required") if self.password.empty?
      if self.password && self.password.length < 5
        self.errors.add("password","too short") 
      end
      if self.password != self.password_confirmation
        self.errors.add("password_confirmation","does not match")
      end
    end
  end
  
  ##
  # Callbacks
  def before_insert_or_update
    encrypt_password
  end
  
  ##
  # Accessors
  attr_accessor :password, :password_confirmation
  
  ##
  # Delete
  def delete(user)
    raise(StandardError, "Cannot delete yourself") if user == self
    raise(StandardError, "Cannot delete only user") if User.count < 2
    remove!(:raise => true)
  end
  
  def self.authenticate(login, password)
    return false if login.empty?
    return false unless user = User.find_one(:login => login)
    Encrypt.compare(password,user['salt'],user['passwd']) ? user : false
  end
  
  def password_required?
    self['passwd'].empty? || !self.password.empty?
  end
  
  protected
  def encrypt_password
    unless password.empty?
      self['salt'] = Encrypt.random_hash
      self['passwd'] = Encrypt.encrypt(password,self['salt'])
      self.password = nil
    end
  end
  
end