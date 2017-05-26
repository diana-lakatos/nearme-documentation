# frozen_string_literal: true
class SubscriptionBookingForm < ActionTypeForm
  class << self
    def decorate(configuration)
      Class.new(self) do
        super
      end
    end
  end

  # @!attribute type
  #   @return [String] must be Transactable::SubscriptionBooking
  property :type, default: 'Transactable::SubscriptionBooking'
end
