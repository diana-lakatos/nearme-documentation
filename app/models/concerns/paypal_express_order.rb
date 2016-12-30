# frozen_string_literal: true
module PaypalExpressOrder
  extend ActiveSupport::Concern

  def express_return_url
    PlatformContext.current.decorate.build_url_for_path("/orders/#{id}/express_checkout/return")
  end

  def express_cancel_return_url
    PlatformContext.current.decorate.build_url_for_path("/orders/#{id}/express_checkout/cancel")
  end


  def setup_authorization_options
    {
      allow_guest_checkout: true,
      items: express_line_items,
      handling: 0,
      currency: currency,
      subtotal: total_amount.cents - shipping_total.cents - total_tax_amount.cents,
      shipping: shipping_total.cents,
      tax: total_tax_amount.cents,
      return_url: express_return_url,
      cancel_return_url: express_cancel_return_url,
      ip: user.last_sign_in_ip
    }
  end


  def express_line_items
    line_items.map do |i|
      {
        name: i.name.try(:strip),
        description: i.respond_to?(:description) ? CustomSanitizer.new.strip_tags(i.description.to_s.strip) : '',
        quantity: i.quantity.to_i,
        amount: i.gross_price_cents
      }
    end
  end
end
