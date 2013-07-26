module Admin::PaymentTransfersHelper
  def admin_payment_transfer_state_label_class(payment_transfer)
    if payment_transfer.transferred?
      'success'
    else
      'default'
    end
  end
end

