# frozen_string_literal: true
class CheckoutForm < BaseForm
  class << self
    def decorate(configuration)
      Class.new(self) do
        %i(payment payment_subscription).each do |property_name|
          next unless configuration[property_name].present?
          property property_name do
            %i(payment_method_id credit_card_token with_delayed_charge).each do |field|
              options = configuration.dig(property_name, field)
              property field, options&.fetch(:property_options, {}) || {}
              validation = options&.delete(:validation)
              validates field, ValidationHash.new(validation).sanitize if validation.present?
            end
          end
          add_validation(property_name, configuration[property_name])
        end
      end
    end
  end

  # @!attribute payment
  #   @return [Hash] contains payment_method_id (numeric identifier for the payment method)
  #     and credit_card_token (represents a credit card with which the user is paying)

end
