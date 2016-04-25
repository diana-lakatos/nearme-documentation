class InstanceAdmin::Reports::TransactablesController < InstanceAdmin::Reports::BaseController

  def destroy
    @transactable = Transactable.find(params[:id])
    TransactableDestroyerService.new(@transactable, event_tracker, @transactable.creator).destroy

    flash[:deleted] = t('flash_messages.instance_admin.reports.listings.successfully_deleted')
    redirect_to instance_admin_reports_transactables_path
  end

  private

  def transactable_params
    params.require(:transactable).permit(secured_params.transactable_for_instance_admin(@resource.transactable_type))
  end

  def set_scopes
    @scope_type_class = ServiceType
    @scope_class = Transactable
    @search_form = InstanceAdmin::TransactableSearchForm
  end
end

