# frozen_string_literal: true
class CheckoutForm < BaseForm
  class << self
    def decorate(configuration)
      Class.new(self) do
        property :payment do
          property :payment_method_id, configuration.dig(:payment, :payment_method_id, :property_options).presence || {}
          validation = configuration.dig(:payment, :payment_method_id).delete(:validation)
          validates :payment_method_id, validation if validation.present?

          property :credit_card_token
          validation = configuration.dig(:payment, :credit_card_token).delete(:validation)
          validates :credit_card_token, validation if validation.present?
        end
        validation = configuration[:payment].delete(:validation)
        validates :payment, validation if validation.present?
      end
    end
  end
end
