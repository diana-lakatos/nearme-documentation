class InstanceAdmin::Manage::ReservationTypesController < InstanceAdmin::Manage::TransactableTypesController
  def create
    @transactable_type = resource_class.new(transactable_type_params)
    if @transactable_type.save
      Utils::FormComponentsCreator.new(@transactable_type).create!
      flash[:success] = t "flash_messages.instance_admin.#{controller_scope}.#{translation_key}.created"
      redirect_to [:instance_admin, controller_scope, resource_class]
    else
      flash[:error] = @transactable_type.errors.full_messages.to_sentence
      render action: :new
    end
  end

  def update
    if resource.update_attributes(transactable_type_params)
      flash.now[:success] = t("flash_messages.instance_admin.#{controller_scope}.#{translation_key}.updated")
      redirect_to [:instance_admin, controller_scope, resource_class]
    else
      flash.now[:error] = resource.errors.full_messages.to_sentence
      render action: :edit
    end
  end

  private

  def resource_class
    ReservationType
  end

  def collection
    @transactable_types ||= resource_class.all
  end

  def resource
    @transactable_type ||= resource_class.find(params[:id])
  end

  def transactable_type_params
    params.require(:reservation_type).permit(secured_params.reservation_type)
  end
end
