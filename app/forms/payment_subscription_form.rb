# frozen_string_literal: true
class PaymentSubscriptionForm < BaseForm
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
        inject_dynamic_fields(configuration, whitelisted: [:payer_id, :payment_method_id, :credit_card_id, :bank_account_id, :payment_source_id, :payment_source_type, :chosen_credit_card_id])
      end
    end
  end

  # @!attribute credit_card_token
  #   @return [String] token string identifying the credit card
  property :credit_card_token, virtual: true
end
