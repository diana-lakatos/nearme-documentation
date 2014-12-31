module Spree
  class OrderMailer < BaseMailer
    def confirm_email(order, resend = false)
      @order = order.respond_to?(:id) ? order : Spree::Order.find(order)
      subject = (resend ? "[#{t('buy_sell_market.checkout.order_mailer.resend')}] " : '')
      subject += "#{t('buy_sell_market.checkout.order_mailer.confirm_email.subject')} ##{@order.number}"
      mail(to: @order.email, from: from_address(@order), subject: subject)
    end


    def cancel_email(order, resend = false)
      @order = order.respond_to?(:id) ? order : Spree::Order.find(order)
      subject = (resend ? "[#{t('buy_sell_market.checkout.order_mailer.resend')}] " : '')
      subject += "#{t('buy_sell_market.checkout.order_mailer.cancel_email.subject')} ##{@order.number}"
      mail(to: @order.email, from: from_address(@order), subject: subject)
    end

    def notify_seller_email(order)
      @order = order.respond_to?(:id) ? order : Spree::Order.find(order)
      subject = "#{t('buy_sell_market.checkout.order_mailer.notify_seller_email.subject')} ##{@order.number}"
      mail(to: @order.email, from: from_address(@order), subject: subject)
    end

    private

    def from_address(order)
      order.company.creator.email
    end
  end
end
