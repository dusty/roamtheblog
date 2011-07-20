class Email
  include MongoMapper::Document

  key :recipients, Array
  key :subject, String
  key :message, String
  key :sent_at, Time
  key :error_msg, String
  timestamps!

  ensure_index :sent_at
  ensure_index :recipients

  validates_presence_of :subject, :message
  validate :validate_recipients

  def self.pending
    where(:sent_at => {"$exists" => false})
  end

  ## Sendgrid headers
  def headers
    {
      'X-SMTPAPI' => {
        'to' => recipients,
        'category' => site.domain
      }.to_json
    }
  end

  def delivered?
    !sent_at.blank?
  end

  def deliver_once
    deliver unless delivered?
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
        :via_options => SMTP_OPTS
      )
      update_attributes(:sent_at => Time.now.utc)
    rescue StandardError => e
      update_attributes(:error_msg => "#{e.class} : #{e.message}")
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
