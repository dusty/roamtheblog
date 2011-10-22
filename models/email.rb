class Email
  include MongoMapper::Document

  key :recipients, Array
  key :subject, String
  key :message, String
  timestamps!

  ensure_index :recipients

  validates_presence_of :subject, :message
  validate :validate_recipients

  after_create :deliver

  scope :recent, sort(:created_at.desc)

  ## Sendgrid headers
  def headers
    {
      'X-SMTPAPI' => {
        'to' => recipients,
        'category' => site.domain
      }.to_json
    }
  end

  def deliver
    begin
      Pony.mail(
        :from => "alerts@#{site.domain}",
        :to => recipients.first,
        :subject => "[#{site.title}] #{subject}",
        :body => message,
        :headers => headers,
        :via => :smtp,
          :via_options => {
            :address => ENV['SMTP_HOST'],
            :user_name => ENV['SMTP_USER'],
            :password => ENV['SMTP_PASS'],
            :port => ENV['SMTP_PORT'],
            :authentication => ENV['SMTP_AUTH'],
            :domain => ENV['SMTP_DOMAIN']
          }
      )
    rescue StandardError => e
      puts "#{e.class} : #{e.message}\n#{e.backtrace}\n"
    end
  end

  protected

  def site
    @site ||= Site.default
  end

  def validate_recipients
    errors.add(:recipients, 'are invalid') unless recipients.all? do |recipient|
      Validator.valid_email?(recipient)
    end
  end

end