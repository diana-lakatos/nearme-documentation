# frozen_string_literal: true
class CheckoutForm < BaseForm
  class << self
    def decorate(configuration)
      Class.new(self) do
        property :payment do
          %i(payment_method_id credit_card_token).each do |field|
            options = configuration.dig(:payment, field)
            add_property(field, options)
            add_validation(field, options)
          end
        end
        add_validation(:payment, configuration[:payment])
      end
    end
  end
end
