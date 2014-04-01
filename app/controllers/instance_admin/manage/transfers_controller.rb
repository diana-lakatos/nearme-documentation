class InstanceAdmin::Manage::TransfersController < InstanceAdmin::Manage::BaseController

  defaults :resource_class => PaymentTransfer, :collection_name => 'transfers', :instance_name => 'transfer'

  def index
  end

  def transferred
    resource.mark_transferred
    flash[:notice] = t('flash_messages.payments.marked_transferred')
    redirect_to instance_admin_manage_transfer_path(resource)
  end

  def payout
    resource.payout
    if resource.transferred?
      flash[:notice] = t('flash_messages.payments.payout_successful')
    elsif resource.payout_attempts.last.confirmation_url.present?
      flash[:warning] = t('flash_messages.payments.payout_need_confirmation')
    elsif resource.payout_attempts.last.should_be_verified_after_time?
      flash[:warning] = t('flash_messages.payments.payout_need_verification')
    else
      flash[:error] = t('flash_messages.payments.payout_failed')
    end
    redirect_to instance_admin_manage_transfer_path(resource)
  end

  protected

  def collection_allowed_scopes
    %w(pending transferred)
  end

  def collection
    @transfers ||= end_of_association_chain.order("created_at DESC").paginate(:page => params[:page])
  end
end
