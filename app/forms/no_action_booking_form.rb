# frozen_string_literal: true
class NoActionBookingForm < ActionTypeForm
  class << self
    def decorate(configuration)
      Class.new(self) do
        super
      end
    end
  end

  # @!attribute type
  #   @return [String] must be Transactable::NoActionBooking
  property :type, default: 'Transactable::NoActionBooking'
end
