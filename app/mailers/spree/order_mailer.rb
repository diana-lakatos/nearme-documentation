module Spree
  class OrderMailer < BaseMailer
    def confirm_email(order, resend = false)
      raise "Should not be invoked"
    end


    def cancel_email(order, resend = false)
      raise "Should not be invoked"
    end

    def notify_seller_email(order)
      raise "Should not be invoked"
    end

  end
end

