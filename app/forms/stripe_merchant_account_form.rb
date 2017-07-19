# frozen_string_literal: true
class StripeMerchantAccountForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections

  property :payment_gateway_id
  validates :payment_gateway_id, presence: true

  property :bank_account_number
  validates :bank_account_number, presence: true

  property :bank_routing_number
  validates :bank_routing_number, presence: true

  property :account_type
  validates :account_type, inclusion: { in: MerchantAccount::StripeConnectMerchantAccount::ACCOUNT_TYPES }

  property :currency

  property :tos, virtual: true
  validates :tos, acceptance: true, presence: true

  collection :owners, form: StripeMerchantAccountOwnerForm.decorate({}),
                      populator: ->(collection:, index:, **) do
                        if item = collection[index]
                          item
                        else
                          collection.insert(index, model.owners.new)
                        end
                      end,
                      prepopulator: ->(_options) { owners << model.owners.build if owners.size.zero? }

  class << self
    def decorate(configuration)
      Class.new(self) do
        inject_dynamic_fields(configuration, whitelisted: [:business_tax_id, :business_name])
      end
    end
  end

  def save(*args)
    super.tap do
      propagate_errors if model.errors.any? || !model.valid?
    end
  end

  private

  def propagate_errors
    model.errors.messages.each do |field, messages|
      errors.add(field, messages)
    end
  end
end
