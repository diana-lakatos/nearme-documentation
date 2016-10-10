class InstanceAdmin::CustomValidatorsController < InstanceAdmin::ResourceController
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

  def resource_class
    fail NotImplementedError
  end

  def find_validatable
    @validatable = resource_class.find(params["#{translation_key.singularize}_id"])
  end

  def translation_key
    @translation_key ||= resource_class.name.demodulize.tableize
  end

  def permitting_controller_class
    @controller_scope ||= 'manage'
  end

  def redirect_path
    polymorphic_url([:instance_admin, @controller_scope, @validatable, :custom_validators])
  end

  def custom_validator_params
    params.require(:custom_validator).permit(secured_params.custom_validator)
  end

  def set_breadcrumbs
    @breadcrumbs_title = BreadcrumbsList.new(
      { url: polymorphic_url([:instance_admin, @controller_scope, resource_class]), title: t('instance_admin.manage.transactable_types.transactable_types') },
      { title: @validatable.name.titleize },
      url: redirect_path, title: t('instance_admin.manage.transactable_types.custom_validators')
    )
    end
end
