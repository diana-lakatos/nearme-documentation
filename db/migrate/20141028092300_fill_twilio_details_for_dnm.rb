class FillTwilioDetailsForDnm < ActiveRecord::Migration

  class Instance < ActiveRecord::Base
    attr_encrypted :twilio_consumer_key, :twilio_consumer_secret,
      :test_twilio_consumer_key, :test_twilio_consumer_secret,
      :key => DesksnearMe::Application.config.secret_token, :if => DesksnearMe::Application.config.encrypt_sensitive_db_columns

    def self.default_instance
      where(name: "DesksNearMe").first || self.first
    end
  end

  def up
    i = Instance.default_instance
    i.twilio_consumer_key  = 'AC5b979a4ff2aa576bafd240ba3f56c3ce'
    i.twilio_consumer_secret = '0f9a2a5a9f847b0b135a94fe2aa7f346'
    i.test_twilio_consumer_key = 'AC83d13764f96b35292203c1a276326f5d'
    i.test_twilio_consumer_secret = '709625e20011ace4b8b53a5a04160026'
    i.twilio_from_number = '+1 510-478-9196'
    i.test_twilio_from_number = '+15005550006'
    i.save(validate: false)
  end

  def down

  end
end
