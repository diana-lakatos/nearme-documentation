class Payout < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context
  acts_as_paranoid
  has_paper_trail
  belongs_to :reference, :polymorphic => true
  belongs_to :instance
  belongs_to :payment_gateway

  scope :successful, -> { where(:success => true) }
  scope :pending, -> { where(:pending => true) }
  scope :failed, -> { where(:pending => false, :success => false) }
  scope :need_status_verification, -> { where('(pending = ? OR success = ?) AND created_at > ? AND created_at < ?', true, true, Time.zone.now - 7.days, Time.zone.now - 1.day) }

  monetize :amount, with_model_currency: :currency

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
    self.reference.try(:success!)
  end

  def payout_failed(response)
    self.success = false
    self.pending = false
    self.response = response.to_yaml
    save!
    self.reference.try(:fail!)
  end

  alias_method :decrypted_response, :response
  def response
    @response_object ||= Billing::Gateway::Processor::Response::ResponseFactory.create(decrypted_response)
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

  def update_status
    reference.try(:update_payout_status, self)
  end

end
