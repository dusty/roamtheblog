class User
  include MongoMapper::Document

  key :name, String
  key :email, String
  key :login, String
  key :passwd, String
  key :salt, String
  key :login_at, Time
  key :token, String
  timestamps!

  attr_accessor :password, :password_confirmation

  ensure_index :login, :unique => true

  validates_presence_of :name
  validates_uniqueness_of :login

  validates_format_of :email, :with => Validator.email
  validates_uniqueness_of :email

  validates_presence_of :password, :if => :password_required?
  validates_length_of :password, :minimum => 5, :if => :password_required?
  validates_confirmation_of :password, :if => :password_required?

  before_validation :normalize_email
  before_save       :encrypt_password
  before_create     :generate_token

  def self.create_user(email)
    return if email.blank?
    user = by_email(email.downcase) || User.new(:email => email)
    user.save(:validate => false) if user.new_record?
    user.send_activation_notice
    user
  end

  def self.by_email(email)
    first(:email => email.downcase) unless email.blank?
  end

  def self.by_login(login)
    first(:login => login) unless login.blank?
  end

  def self.authenticate(login, password)
    return false unless user = User.by_login(login)
    Encrypt.compare(password,user.salt,user.passwd) ? user : false
  end

  def self.authenticate_by_token(email,token)
    first(:email => email.downcase, :token => token) unless email.blank? || token.blank?
  end

  def self.forgot_password(email)
    return false unless user = by_email(email)
    user.generate_token
    user.save && user.send_email_password
  end

  def self.recent(limit=0)
    sort([:login_at, :desc]).limit(limit.to_i)
  end

  def self.create_default
    return false unless count == 0
    user = new(:login => 'admin', :name => 'admin')
    user.password, user.password_confirmation = 'admin', 'admin'
    user.save(:validate => false) && user
  end

  def record_login
    update_attributes(:login_at => Time.now.utc)
  end

  def send_email(subject,message)
    Email.new(:recipients => [email], :subject => subject, :message => message).save
  end

  def send_email_password
    send_email("Password Reset", password_message) unless token.blank?
  end

  def send_email_activation
    send_email("Welcome to #{site.title}", activation_message) unless activated?
  end

  def generate_token
    self.token = Encrypt.random_hash
  end

  protected

  def normalize_email
    self.email = Validator.normalize_email(email) || email
  end

  def password_required?
    passwd.blank? || !password.blank?
  end

  def encrypt_password
    unless password.blank?
      self.salt = Encrypt.random_hash
      self.passwd = Encrypt.encrypt(password,salt)
      self.password = nil
      self.token = nil
    end
  end

  def password_message
    <<-EOD
Your password was recently requested to be reset.  Please click on the link
below to be taken to #{site.title}, where you will be able to change
your password.

http://www.#{site.domain}/activation?email=#{email}&token=#{token}

If you did not request this password change, do nothing and your account will
not be changed.

Thanks!
    EOD
  end

  def activation_message
    <<-EOD

Welcome to #{site.title}!

An account was registered to #{site.title} for the following email address:

#{email}

If you have NOT requested this, then do nothing and your account will
remain inactive.

If you have requested this, you may complete the registration process by
visiting the following link:

http://www.#{site.domain}/activation?email=#{email}&token=#{token}


Thanks!
    EOD
  end

end
