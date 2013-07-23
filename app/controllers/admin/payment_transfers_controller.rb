class Admin::PaymentTransfersController < Admin::ResourceController

  def transferred
    resource.mark_transferred
    flash[:notice] = "Marked payment transfer as transferred"
    redirect_to [:admin, :payment_transfers]
  end

  # Generate a batch of payment transfers from unpaidout reservation charges.
  def generate
    PaymentTransferScheduler.new.perform
    pending_payments = collection.pending.count
    flash[:notice] = "Ran the payment transfer scheduler. There are now #{pending_payments} pending payments."
    redirect_to [:admin, :payment_transfers]
  end

  protected

  def collection_allowed_scopes
    %w(pending transferred)
  end

  def collection_default_scope
    'pending'
  end

end

