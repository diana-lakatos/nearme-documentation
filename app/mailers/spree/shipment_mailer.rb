module Spree
  class ShipmentMailer < BaseMailer
    def shipped_email(shipment, resend = false)
      raise "Should not be invoked"
    end
  end
end
