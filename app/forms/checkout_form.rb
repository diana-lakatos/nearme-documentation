# frozen_string_literal: true
class CheckoutForm < BaseForm
  class << self
    def decorate(configuration)
      Class.new(self) do
        property :payment do
          %i(payment_method_id credit_card_token).each do |field|
            options = configuration.dig(:payment, field)
            property field, options&.fetch(:property_options, {}) || {}
            validation = options&.delete(:validation)
            validates field, ValidationHash.new(validation).sanitize if validation.present?
          end
        end
        add_validation(:payment, configuration[:payment])
      end
    end
  end
end
