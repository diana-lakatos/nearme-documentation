class Refund < ActiveRecord::Base
  include Encryptable
  acts_as_paranoid
  has_paper_trail
  auto_set_platform_context
  scoped_to_platform_context

  scope :successful, -> { where(:success => true) }
  scope :failed, -> { where(:success => false) }
  belongs_to :payment
  belongs_to :payment_gateway

  monetize :amount, with_model_currency: :currency
  serialize :response, Hash

  attr_encrypted :response, marshal: true

  def refund_successful(response)
    self.success = true
    self.response = response
    save!
  end

  def refund_failed(response)
    self.success = false
    self.response = response
    save!
  end

end
