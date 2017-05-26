# frozen_string_literal: true
class OfferActionForm < ActionTypeForm
  class << self
    def decorate(configuration)
      Class.new(self) do
        super
      end
    end
  end

  # @!attribute type
  #   @return [String] must be Transactable::OfferAction
  property :type, default: 'Transactable::OfferAction'
end
