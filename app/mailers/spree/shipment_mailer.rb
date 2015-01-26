module Spree
  class ShipmentMailer < BaseMailer
    def shipped_email(shipment, resend = false)
      @shipment = shipment.respond_to?(:id) ? shipment : Spree::Shipment.find(shipment)
      subject = (resend ? "[#{t('buy_sell_market.checkout.shipment_mailer.resend')}] " : '')
      subject += "#{t('buy_sell_market.checkout.shipment_mailer.shipped_email.subject')} ##{@shipment.order.number}"
      mail(to: @shipment.order.email, from: from_address(@shipment), subject: subject)
    end

    private

    def from_address(shipment)
      shipment.order.company.users.first.email
    end
  end
end
