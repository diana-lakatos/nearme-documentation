# frozen_string_literal: true
# TODO: delete
class InstanceAdmin::ShippingOptions::DimensionsTemplatesController < InstanceAdmin::ShippingOptions::BaseController
  before_action :set_breadcrumbs

  def index
    @dimensions_templates = current_instance.dimensions_templates
  end

  def new
    @breadcrumbs_title = 'New Dimension Template'
    @dimensions_template = current_instance.dimensions_templates.build
  end

  def create
    @dimensions_template = current_instance.dimensions_templates.build(template_params)
    @dimensions_template.creator = current_user
    @dimensions_template.entity = current_instance

    dimensions_template_editor = DimensionsTemplateEditorService.new(@dimensions_template)
    if dimensions_template_editor.save
      flash[:success] = t('flash_messages.shipping_options.dimensions_templates.template_added')
      redirect_to instance_admin_shipping_options_dimensions_templates_path
    else
      render :new
    end
  end

  def edit
    @dimensions_template = current_instance.dimensions_templates.find(params[:id])
  end

  def update
    @dimensions_template = current_instance.dimensions_templates.find(params[:id])

    dimensions_template_editor = DimensionsTemplateEditorService.new(@dimensions_template)
    if dimensions_template_editor.update_attributes(template_params)
      flash[:success] = t('flash_messages.shipping_options.dimensions_templates.template_updated')
      redirect_to instance_admin_shipping_options_dimensions_templates_path
    else
      render 'edit'
    end
  end

  def destroy
    @dimensions_template = current_instance.dimensions_templates.find(params[:id])
    @dimensions_template.destroy
    flash[:success] = t('flash_messages.shipping_options.dimensions_templates.template_deleted')
    redirect_to instance_admin_shipping_options_dimensions_templates_path
  end

  private

  def set_breadcrumbs
    @breadcrumbs_title = 'Dimensions Templates'
  end

  def template_params
    params.require(:dimensions_template).permit(secured_params.dimensions_template)
  end
end
