# frozen_string_literal: true
require 'plaid'

# PaymentMethod::AchPaymentMethod is responsible for management of setting for Stripe ACH method
class PaymentMethod::AchPaymentMethod < PaymentMethod
  PLAID_ENVIRONMENTS = %w(sandbox development production).map(&:to_sym).freeze
  PLAID_SETTINGS_KEYS = %w(client_id public_key secret env).freeze

  has_many :payment_sources, class_name: 'BankAccount', foreign_key: 'payment_method_id'

  def name
    "ACH"
  end

  def self.settings
    {
      client_id: { validate: [:presence], label:  'Plaid client_id' },
      public_key: { validate: [:presence], label: 'Plaid public_key' },
      secret: { validate: [:presence], label: 'Plaid secret' },
      env: { collection: PLAID_ENVIRONMENTS, validate: [:presence], label: 'Environment' }
    }
  end

  def key
    settings && settings[:public_key]
  end

  def plaid_configured?
    key.present? && settings[:client_id].present? && settings[:secret].present?
  end

  def plaid_client
    Plaid::Client.new(plaid_settings)
  end

  def plaid_settings
    settings.slice(*PLAID_SETTINGS_KEYS).symbolize_keys.merge(env: environment)
  end

  def environment
    (settings.try('[]', 'env') || 'sandbox').to_sym
  end
end
