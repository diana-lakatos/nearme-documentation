class Payout < ActiveRecord::Base
  acts_as_paranoid
  has_paper_trail
  belongs_to :reference, :polymorphic => true

  scope :successful, where(:success => true)
  scope :pending, where(:pending => true)
  scope :failed, where(:pending => false, :success => false)

  monetize :amount

  attr_encrypted :response, :key => DesksnearMe::Application.config.secret_token, :if => DesksnearMe::Application.config.encrypt_sensitive_db_columns

  def payout_pending(response)
    self.pending = true
    self.response = response.to_yaml
    save!
  end

  def payout_successful(response = nil)
    self.success = true
    self.pending = false
    self.response = response.to_yaml if response
    save!
  end

  def payout_failed(response)
    self.success = false
    self.pending = false
    self.response = response.to_yaml
    save!
  end

  alias_method :decrypted_response, :response
  def response
    @response_object ||= Billing::Gateway::Processor::ResponseFactory.create(decrypted_response)
  end

  def failure_message
    response.failure_message
  end

  def should_be_verified_after_time?
    pending? && response.should_be_verified_after_time?
  end

  def verify_after_time_arguments
    response.verify_after_time_arguments
  end

  def failed?
    !success && !pending
  end

  def confirmation_url
    response.confirmation_url if pending? && !reference.transferred?
  end

end
