class Payout < ActiveRecord::Base
  acts_as_paranoid
  has_paper_trail
  belongs_to :reference, :polymorphic => true

  scope :successful, where(:success => true)
  scope :pending, where('payouts.pending is not null')
  scope :failed, where(:pending => nil, :success => false)

  monetize :amount

  attr_encrypted :response, :key => DesksnearMe::Application.config.secret_token, :if => DesksnearMe::Application.config.encrypt_sensitive_db_columns

  def payout_pending(response, confirmation_url)
    self.pending = confirmation_url
    self.response = response.to_yaml
    save!
  end

  def payout_successful(response = nil)
    self.success = true
    self.pending = nil
    self.response = response.to_yaml if response
    save!
  end

  def payout_failed(response)
    self.success = false
    self.pending = nil
    self.response = response.to_yaml
    save!
  end

  def failed?
    !success && pending.nil?
  end

  def failure_message
    response_object = YAML.load(self.response.gsub('Proc {}', ''))
    if self.response.include?('PayPal')
      response_object.first.message
    else
      "failed"
    end
  end

  def confirmation_url
    if self.response.include?('PayPal')
      self.pending
    end
  end

end
