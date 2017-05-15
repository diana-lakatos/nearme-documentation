# frozen_string_literal: true
require 'active_merchant/billing/gateways/paypal/paypal_express_response'

class Charge < ActiveRecord::Base
  include Encryptable
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :user
  belongs_to :payment, -> { with_deleted }
  belongs_to :payment_gateway

  scope :successful, -> { where(success: true) }
  scope :failed, -> { where(success: false) }

  serialize :response, Hash

  attr_encrypted :response, marshal: true

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
