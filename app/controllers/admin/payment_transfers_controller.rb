class Admin::PaymentTransfersController < Admin::ResourceController

  def transferred
    resource.mark_transferred
    flash[:notice] = "Marked payment transfer as transferred"
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

