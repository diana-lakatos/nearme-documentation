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
    @transfers ||= begin
                scope = end_of_association_chain.for_instance(platform_context.instance)
                # Order the collection by created_at descending
                scope = scope.order("created_at DESC")

                # Paginate the collection
                scope.paginate(:page => params[:page])
              end
  end
end
