# frozen_string_literal: true
class PurchaseActionForm < ActionTypeForm
  class << self
    def decorate(configuration)
      Class.new(self) do
        super
      end
    end
  end

  # @!attribute type
  #   @return [String] must be Transactable::PurchaseAction
  property :type, default: 'Transactable::PurchaseAction'
end
