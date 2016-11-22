# frozen_string_literal: true
class Refund < ActiveRecord::Base
  RECEIVERS = %w(mpo host guest).freeze

  include Encryptable
  acts_as_paranoid
  has_paper_trail
  auto_set_platform_context
  scoped_to_platform_context

  serialize :response, Hash
  attr_encrypted :response, marshal: true

  belongs_to :payment
  belongs_to :payment_gateway

  scope :guest, -> { where(receiver: 'guest') }
  scope :host, -> { where(receiver: 'host') }
  scope :mpo, -> { where(receiver: 'mpo') }
  scope :successful, -> { where(success: true) }
  scope :failed, -> { where(success: false) }

  monetize :amount_cents, with_model_currency: :currency

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
