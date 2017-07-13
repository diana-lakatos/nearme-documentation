# frozen_string_literal: true
# InstanceClient is a class representing Customer saved in PaymentGateway
# Every InstanceClient has many CC and Bank Accounts synced within payment gateway account

class InstanceClient < ActiveRecord::Base
  include Encryptable
  auto_set_platform_context
  scoped_to_platform_context
  acts_as_paranoid

  attr_encrypted :response

  # Company or User
  belongs_to :client, polymorphic: true
  belongs_to :instance
  belongs_to :payment_gateway

  has_many :credit_cards
  has_many :bank_accounts
  before_save :clear_decorator, if: ->(ic) { ic.encrypted_response_changed? }

  validates :client_id, :client_type, presence: { unless: ->(ic) { ic.client.present? } }

  scope :for_payment_gateway, ->(payment_gateway, test_mode) { where(payment_gateway: payment_gateway, test_mode: test_mode) }
  scope :mode_scope, -> { PlatformContext.current.instance.test_mode? ? where(test_mode: true) : where(test_mode: false) }

  def credit_card
    credit_cards.default
  end

  def decorator
    @decorator ||= case payment_gateway.name
                   when 'Stripe'
                     InstanceClient::StripeDecorator.new(self)
                   when 'Stripe Connect'
                     InstanceClient::StripeDecorator.new(self)
                   when 'Braintree'
                     InstanceClient::BraintreeDecorator.new(self)
                   when 'Braintree Marketplace'
                     InstanceClient::BraintreeDecorator.new(self)
                   when nil
                     nil
                   end
  end

  def customer_id
    decorator.try(:customer_id)
  end

  def find
    return false unless customer_id
    decorator.try(:find)
  end

  private

  def clear_decorator
    @decorator = nil
  end
end
