# frozen_string_literal: true
class PaymentSubscriptionForm < BaseForm
  class << self
    def decorate(configuration)
      Class.new(self) do
        inject_dynamic_fields(configuration, whitelisted: [:payer_id, :payment_method_id, :credit_card_id, :bank_account_id, :payment_source_id, :payment_source_type, :chosen_credit_card_id])

        def credit_card_token=(token)
          model.payer = model.subscriber.creator
          model.payment_source = CreditCard.new(credit_card_token: token,
                                                payment_method_id: payment_method_id,
                                                payer: model.subscriber.creator)
        end
      end
    end
  end

  def save!(*args)
    super
    model.process!
  end

  # @!attribute credit_card_token
  #   @return [String] token string identifying the credit card
  property :credit_card_token, virtual: true
end
