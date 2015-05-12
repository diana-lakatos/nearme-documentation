class Charge < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :user
  belongs_to :payment
  belongs_to :payment_gateway

  scope :successful, -> { where(:success => true) }

  monetize :amount, :as => :price, with_model_currency: :currency
  serialize :response, Hash

  attr_encrypted :response, :key => DesksnearMe::Application.config.secret_token, marshal: true

  def charge_successful(response)
    self.success = true
    self.response = response
    save!
  end

  def charge_failed(response)
    self.success = false
    self.response = response
    save!
  end
end
