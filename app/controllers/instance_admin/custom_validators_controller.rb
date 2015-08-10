class InstanceAdmin::CustomValidatorsController  < InstanceAdmin::ResourceController

  before_filter :find_validatable
  before_filter :available_attributes, only: [:edit, :new]
  before_filter :set_breadcrumbs


  def create
    @custom_validator = @validatable.custom_validators.create custom_validator_params
    create!(success: t('flash_messages.instance_admin.manage.form_component.created')) { redirect_path }
  end

  def edit
    resource.set_accessors
  end

  def update
    update!(success: t('flash_messages.instance_admin.manage.form_component.updated')) { redirect_path }
  end

  def destroy
    destroy!(success: t('flash_messages.instance_admin.manage.form_component.deleted')) { redirect_path }
  end


  private

  def collection
    @validators ||= @validatable.custom_validators
  end

  def resource
    @validator ||= params[:id] ? @validatable.custom_validators.find(params[:id]) : @validatable.custom_validators.new
  end

  def find_validatable
    raise NotImplementedError
  end

  def permitting_controller_class
    'manage'
  end

  def custom_validator_params
    params.require(:custom_validator).permit(secured_params.custom_validator)
  end

  def set_breadcrumbs
    @breadcrumbs_title = BreadcrumbsList.new(
      { :url => instance_admin_manage_service_types_path, :title => t('instance_admin.manage.service_types.service_types') },
      { :url => instance_admin_manage_service_type_custom_validators_path, :title => t('instance_admin.manage.service_types.custom_validators') }
    )
  end
end
