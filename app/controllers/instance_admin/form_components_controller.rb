# frozen_string_literal: true
class InstanceAdmin::FormComponentsController < InstanceAdmin::ResourceController
  before_action :find_form_componentable
  before_action :set_breadcrumbs_title

  def index
    @form_components = @form_componentable.form_components.rank(:rank).order('form_type')
  end

  def new
    @form_type = params[:form_type]
    @form_component = @form_componentable.form_components.build(form_type: @form_type)
  end

  def create
    @form_component = @form_componentable.form_components.build(form_component_params)
    if @form_component.save
      FormComponentToFormConfiguration.new(Instance.where(id: PlatformContext.current.instance.id)).go!
      flash[:success] = t 'flash_messages.instance_admin.manage.form_component.created'
      redirect_to redirect_path
    else
      # This will not  happen unless the user plays with the console and is mainly done to make
      # the view renderable so tests can pass; can't use ||= because it may be a blank string
      @form_component.form_type = FormComponent::SPACE_WIZARD if @form_component.form_type.blank?

      flash.now[:error] = @form_component.errors.full_messages.to_sentence
      render action: :new
    end
  end

  def create_as_copy
    transactable_type_id = params[:copy_template][:form_componentable_id]
    form_type = params[:copy_template][:form_type]
    resource_class.find(transactable_type_id).form_components.where(form_type: form_type).each do |form_component|
      @form_componentable.form_components << form_component.dup
    end
    redirect_to redirect_path
  end

  def edit
    @form_component = @form_componentable.form_components.find(params[:id])
  end

  def update
    @form_component = @form_componentable.form_components.find(params[:id])

    if @form_component.update_attributes(form_component_params)
      FormComponentToFormConfiguration.new(Instance.where(id: PlatformContext.current.instance.id)).go!
      flash[:success] = t 'flash_messages.instance_admin.manage.form_component.updated'
      redirect_to redirect_path
    else
      # This will not  happen unless the user plays with the console and is mainly done to make
      # the view renderable so tests can pass
      @form_component.form_type = FormComponent::SPACE_WIZARD if @form_component.form_type.blank?

      flash.now[:error] = @form_component.errors.full_messages.to_sentence
      render action: :edit
    end
  end

  def destroy
    @form_component = @form_componentable.form_components.find(params[:id])
    @form_component.destroy
    flash[:success] = t 'flash_messages.instance_admin.manage.form_component.deleted'
    redirect_to redirect_path
  end

  def update_rank
    @form_component = @form_componentable.form_components.find(params[:id])
    @form_component.update_attribute(:rank_position, params[:rank_position])
    respond_to do |format|
      format.json do
        render json: { success: true }
      end
    end
  end

  private

  def resource_class
    raise NotImplementedError
  end

  def find_form_componentable
    @form_componentable = resource_class.find(params["#{translation_key.singularize}_id"])
  end

  def translation_key
    @translation_key ||= resource_class.name.demodulize.tableize
  end

  def permitting_controller_class
    @controller_scope ||= 'manage'
  end

  def redirect_path
    [:instance_admin, @controller_scope, @form_componentable, :form_components]
  end

  def set_breadcrumbs_title
    @breadcrumbs_title = BreadcrumbsList.new(
      { url: polymorphic_url([:instance_admin, @controller_scope, resource_class]), title: t("instance_admin.#{@controller_scope}.#{translation_key}.#{translation_key}") },
      { title: @form_componentable.name.titleize },
      title: t('instance_admin.manage.transactable_types.form_components')
    )
  end

  def form_component_params
    params.require(:form_component).permit(secured_params.form_component).tap do |whitelisted|
      whitelisted[:form_fields] = params[:form_component][:form_fields].map { |el| el = el.split('=>'); { el[0].try(:strip) => el[1].try(:strip) } } if params[:form_component][:form_fields]
      whitelisted[:form_fields] ||= []
    end
  end
end
