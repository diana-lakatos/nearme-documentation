# frozen_string_literal: true
class NoActionBookingForm < ActionTypeForm
  property :type, default: 'Transactable::NoActionBooking'

  class << self
    def decorate(configuration)
      Class.new(self) do
        super
      end
    end
  end
end
