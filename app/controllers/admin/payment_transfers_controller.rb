class Admin::PaymentTransfersController < Admin::ResourceController
  before_filter :filter_scope

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

  def filter_scope
    unless %w(pending transferred).include?(params[:scope])
      params[:scope] = 'pending'
    end
  end

  def collection
    case params[:scope]
    when 'pending'
      super.pending
    when 'transferred'
      super.transferred
    end.order('created_at desc')
  end

end

