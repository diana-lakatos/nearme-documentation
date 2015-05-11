class InstanceAdmin::CustomValidatorsController  < InstanceAdmin::ResourceController

  before_filter :find_validatable
  before_filter :available_attributes, only: [:edit, :new]


  def create
    @custom_validator = @validatable.custom_validators.create custom_validator_params
    create!(success: t('flash_messages.instance_admin.manage.form_component.created')) { redirect_path }
    # @form_component = @validatable.form_components.build(form_component_params)
    # if @form_component.save
    #   flash[:success] = t 'flash_messages.instance_admin.manage.form_component.created'
    #   redirect_to redirect_path
    # else
    #   # This will not  happen unless the user plays with the console and is mainly done to make
    #   # the view renderable so tests can pass; can't use ||= because it may be a blank string
    #   @form_component.form_type = FormComponent::SPACE_WIZARD if @form_component.form_type.blank?

    #   flash[:error] = @form_component.errors.full_messages.to_sentence
    #   render action: :new
    # end
  end

  def edit
    resource.set_accessors
  end

  def update
    update!(success: t('flash_messages.instance_admin.manage.form_component.updated')) { redirect_path }

    # @form_component = @validatable.form_components.find(params[:id])
    # if @form_component.update_attributes(form_component_params)
    #   flash[:success] = t 'flash_messages.instance_admin.manage.form_component.updated'
    #   redirect_to redirect_path
    # else
    #   # This will not  happen unless the user plays with the console and is mainly done to make
    #   # the view renderable so tests can pass
    #   @form_component.form_type = FormComponent::SPACE_WIZARD if @form_component.form_type.blank?

    #   flash[:error] = @form_component.errors.full_messages.to_sentence
    #   render action: :edit
    # end
  end

  def destroy
    # @form_component = @validatable.form_components.find(params[:id])
    # @form_component.destroy
    # flash[:success] = t 'flash_messages.instance_admin.manage.form_component.deleted'
    # redirect_to redirect_path

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
end
