# frozen_string_literal: true
class PurchaseActionForm < ActionTypeForm
  property :type, default: 'Transactable::PurchaseAction'

  class << self
    def decorate(configuration)
      Class.new(self) do
        super
      end
    end
  end
end
