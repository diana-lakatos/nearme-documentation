# frozen_string_literal: true
class SubscriptionBookingForm < ActionTypeForm
  property :type, default: 'Transactable::SubscriptionBooking'

  class << self
    def decorate(configuration)
      Class.new(self) do
        super
      end
    end
  end
end
