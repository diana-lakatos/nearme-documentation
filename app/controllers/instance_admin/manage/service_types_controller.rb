class InstanceAdmin::Manage::ServiceTypesController < InstanceAdmin::Manage::TransactableTypesController

  def create
    @service_type = ServiceType.new(transactable_type_params.merge(
      buyable: false,
      availability_options: { "defer_availability_rules" => true, "confirm_reservations" => { "default_value" => true, "public" => true } }
    ))
    if @service_type.save
      at = @service_type.availability_templates.build(name: "Working Week", description: "Mon - Fri, 9:00 AM - 5:00 PM")
      (1..5).each do |i|
        at.availability_rules.build(day: i, open_hour: 9, open_minute: 0,close_hour: 17, close_minute: 0)
      end
      at.save!
      Utils::FormComponentsCreator.new(@service_type).create!
      @service_type.create_rating_systems
      flash.now[:success] = t 'flash_messages.instance_admin.manage.service_types.created'
      redirect_to instance_admin_manage_service_types_path
    else
      flash.now[:error] = @service_type.errors.full_messages.to_sentence
      render action: :new
    end
  end

  def update
    if resource.update_attributes(transactable_type_params)
      resource.schedule.try(:create_schedule_from_schedule_rules) if PlatformContext.current.instance.priority_view_path == 'new_ui'
      flash.now[:success] = t 'flash_messages.instance_admin.manage.service_types.updated'
      redirect_to instance_admin_manage_service_types_path
    else
      flash.now[:error] = resource.errors.full_messages.to_sentence
      render action: params[:action_name]
    end
  end

  def change_state
    @transactable_type = TransactableType.find(params[:id])
    @transactable_type.update(service_type_state_params)
    render nothing: true, status: 200
  end

  private

  def resource_class
    ServiceType
  end

  def service_type_state_params
    params.require(:service_type).permit(:enable_reviews, :show_reviews_if_both_completed)
  end

end

