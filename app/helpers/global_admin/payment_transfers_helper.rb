module GlobalAdmin::PaymentTransfersHelper
  def admin_payment_transfer_state_label_class(payment_transfer)
    if payment_transfer.transferred?
      'success'
    else
      'default'
    end
  end
  alias_method :instance_admin_transfer_state_label_class, :admin_payment_transfer_state_label_class
end
