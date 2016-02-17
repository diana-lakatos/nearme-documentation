class InstanceAdmin::Manage::RatingSystemsController < InstanceAdmin::Manage::BaseController
  def index
    @transactable_types = TransactableType.includes(:rating_systems).order(id: :asc).all
  end

  def update_systems
    @transactable_type = TransactableType.find(params[:transactable_type_id])
    @transactable_type.update(rating_system_params)
    redirect_to instance_admin_manage_rating_systems_path, notice: t('flash_messages.instance_admin.manage.rating_systems.updated')
  end

  private

  def rating_system_params
    params.require(:transactable_type).permit(secured_params.rating_systems)
  end
end
