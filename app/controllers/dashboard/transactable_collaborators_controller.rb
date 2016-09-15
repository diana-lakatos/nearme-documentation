class Dashboard::TransactableCollaboratorsController < Dashboard::BaseController

  before_filter :find_transactable

  def destroy
    respond_to do |format|
      if @transactable.pending? && !@transactable.line_item_orders.where.not(confirmed_at: nil).where(user: @transactable_collaborator.user).exists?
        @transactable_collaborator.actor = current_user
        @transactable_collaborator.destroy
        format.html do
          flash[:notice] = I18n.t('transactable_collaborator.collaborator_cancelled')
          redirect_to dashboard_company_transactable_type_transactables_path(@transactable.transactable_type)
        end
        format.json { render json: { result: 'OK' } }
      else
        format.html do
          flash[:error] = I18n.t('transactable_collaborator.cant_remove_collaborator')
          redirect_to dashboard_company_transactable_type_transactables_path(@transactable.transactable_type)
        end
        format.json { render json: { result: I18n.t('transactable_collaborator.cant_remove_collaborator') }}
      end
    end
  end

  private

  def find_transactable
    @transactable_collaborator = current_user.transactable_collaborators.find(params[:id])
    @transactable = @transactable_collaborator.transactable
  end
end
