class InstanceAdmin::ShippingOptions::DimensionsTemplatesController < InstanceAdmin::ShippingOptions::BaseController
  before_filter :set_breadcrumbs

  def index
    @dimensions_templates = DimensionsTemplate.all
  end

  def new
    @breadcrumbs_title = 'New Dimension Template'
    @dimensions_template = DimensionsTemplate.all.build
  end

  def create
    @dimensions_template = DimensionsTemplate.all.build(template_params)
    @dimensions_template.creator = current_user
    if @dimensions_template.save
      flash[:success] = t('flash_messages.shipping_options.dimensions_templates.template_added')
      redirect_to instance_admin_shipping_options_dimensions_templates_path
    else
      render :new
    end
  end

  def edit
    @dimensions_template = DimensionsTemplate.find(params[:id])
  end

  def update
    @dimensions_template = DimensionsTemplate.find(params[:id])
    if @dimensions_template.update_attributes(template_params)
      flash[:success] = t('flash_messages.shipping_options.dimensions_templates.template_updated')
      redirect_to instance_admin_shipping_options_dimensions_templates_path
    else
      render 'edit'
    end
  end

  def destroy
    @dimensions_template = DimensionsTemplate.find(params[:id])
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
