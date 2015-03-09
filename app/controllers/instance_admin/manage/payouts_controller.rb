class InstanceAdmin::Manage::PayoutsController < InstanceAdmin::Manage::BaseController

  skip_before_filter :check_if_locked

  def update_status
    @payout = Payout.find(params[:id])
    if @payout.update_status
      flash[:notice] = "Status has been updated!"
    else
      flash[:notice] = "Status has not changed yet."
    end
    redirect_to instance_admin_manage_transfer_path(@payout.reference)
  end

end
