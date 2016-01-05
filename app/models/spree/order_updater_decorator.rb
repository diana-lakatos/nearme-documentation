Spree::OrderUpdater.class_eval do
  def update_payment_state
    if order.has_successful_payments? || order.is_free?
      order.payment_state = 'paid'
    elsif order.has_refunded_payments?
      order.payment_state = 'refunded'
    elsif !order.has_any_payment?
      order.payment_state = 'pending'      
    else
      order.payment_state = 'failed'
    end
  end
end
