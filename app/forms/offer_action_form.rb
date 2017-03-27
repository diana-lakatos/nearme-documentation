# frozen_string_literal: true
class OfferActionForm < ActionTypeForm
  property :type, default: 'Transactable::OfferAction'

  class << self
    def decorate(configuration)
      Class.new(self) do
        super
      end
    end
  end
end
