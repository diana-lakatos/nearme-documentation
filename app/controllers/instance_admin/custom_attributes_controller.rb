# frozen_string_literal: true
class InstanceAdmin::CustomAttributesController < InstanceAdmin::ResourceController
  before_action :find_target
  before_action :normalize_valid_values, only: [:create, :update]
  before_action :set_breadcrumbs

  def index
    @custom_attributes = @target.custom_attributes.order('name')
  end

  def new
    unless @custom_attribute = @target.custom_attributes.build
      flash[:error] = t 'flash_messages.instance_admin.manage.custom_attributes.invalid'
      redirect_to redirection_path
    end
  end

  def edit
    @custom_attribute = @target.custom_attributes.listable.find(params[:id])
    @custom_attribute.required = begin
                                   @custom_attribute.validation_rules['presence'] == {}
                                 rescue
                                   false
                                 end
    @custom_attribute.min_length = begin
                                     @custom_attribute.validation_rules['length']['minimum']
                                   rescue
                                     nil
                                   end
    @custom_attribute.max_length = begin
                                     @custom_attribute.validation_rules['length']['maximum']
                                   rescue
                                     nil
                                   end
  end

  def create
    @custom_attribute = @target.custom_attributes.build(custom_attributes_params)
    if @custom_attribute.save
      FormComponentToFormConfiguration.new(PlatformContext.current.instance).go!
      flash[:success] = t 'flash_messages.instance_admin.manage.custom_attributes.created'
      redirect_to redirection_path
    else
      flash.now[:error] = @custom_attribute.errors.full_messages.to_sentence
      render action: :new
    end
  end

  def update
    @custom_attribute = @target.custom_attributes.find(params[:id])
    @custom_attribute.attributes = custom_attributes_params
    if @custom_attribute.save
      FormComponentToFormConfiguration.new(PlatformContext.current.instance).go!
      flash[:success] = t 'flash_messages.instance_admin.manage.custom_attributes.updated'
      redirect_to redirection_path
    else
      flash.now[:error] = @custom_attribute.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    @custom_attribute = @target.custom_attributes.find(params[:id])
    @custom_attribute.destroy
    flash[:success] = t 'flash_messages.instance_admin.manage.custom_attributes.deleted'
    redirect_to redirection_path
  end

  protected

  def resource_class
    raise NotImplementedError
  end

  def set_breadcrumbs
    @breadcrumbs_title = BreadcrumbsList.new(
      { url: polymorphic_url([:instance_admin, @controller_scope, resource_class]), title: t("instance_admin.#{@controller_scope}.#{translation_key}.#{translation_key}") },
      { title: @target.name.titleize },
      title: t('instance_admin.manage.transactable_types.custom_attributes')
    )
  end

  def redirection_path
    [:instance_admin, @controller_scope, @target, :custom_attributes]
  end

  def find_target
    @target ||= resource_class.find(params["#{translation_key.singularize}_id"])
  end

  def translation_key
    @translation_key ||= resource_class.name.demodulize.tableize
  end

  def normalize_valid_values
    params[:custom_attribute][:valid_values] = params[:custom_attribute][:valid_values].split(',').map(&:strip) if params[:custom_attribute] && params[:custom_attribute][:valid_values]
  end

  def custom_attributes_params
    params.require(:custom_attribute).permit(secured_params.custom_attribute).tap do |whitelisted|
      whitelisted[:wrapper_html_options] = params[:custom_attribute][:wrapper_html_options] if params[:custom_attribute] && params[:custom_attribute][:wrapper_html_options]
    end
  end
end
