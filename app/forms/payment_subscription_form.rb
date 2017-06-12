# frozen_string_literal: true
class PaymentSubscriptionForm < BaseForm
  property :credit_card_token, virtual: true

  def credit_card_token=(token)
    model.payment_source = CreditCard.new(credit_card_token: token,
                                          instance_client: model.payment_source.instance_client,
                                          payment_method: model.payment_method,
                                          payer: model.payer)
    model.process!
  end

  class << self
    def decorate(configuration)
      Class.new(self) do
        inject_dynamic_fields(configuration)
      end
    end
  end
end
