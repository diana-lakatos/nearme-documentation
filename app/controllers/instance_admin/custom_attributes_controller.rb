class InstanceAdmin::CustomAttributesController < InstanceAdmin::ResourceController

  before_filter :find_target
  before_filter :normalize_valid_values, only: [:create, :update]
  before_filter :set_breadcrumbs

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
    @custom_attribute.required = @custom_attribute.validation_rules['presence'] == {} rescue false
    @custom_attribute.min_length = @custom_attribute.validation_rules['length']['minimum'] rescue nil
    @custom_attribute.max_length = @custom_attribute.validation_rules['length']['maximum'] rescue nil
  end

  def create
    @custom_attribute = @target.custom_attributes.build(custom_attributes_params)
    @custom_attribute.set_validation_rules
    if @custom_attribute.save
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
    @custom_attribute.set_validation_rules
    if @custom_attribute.save
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

  def set_breadcrumbs
    @breadcrumbs_title = 'Manage Attributes'
  end

  def redirection_path
    raise NotImplementedError
  end

  def find_target
    raise NotImplementedError
  end

  def normalize_valid_values
      params[:custom_attribute][:valid_values] = params[:custom_attribute][:valid_values].split(',').map(&:strip) if params[:custom_attribute] && params[:custom_attribute][:valid_values]
  end

  def custom_attributes_params()
    params.require(:custom_attribute).permit(secured_params.custom_attribute).tap do |whitelisted|
      whitelisted[:wrapper_html_options] = params[:custom_attribute][:wrapper_html_options] if params[:custom_attribute] && params[:custom_attribute][:wrapper_html_options]
    end
  end

end
