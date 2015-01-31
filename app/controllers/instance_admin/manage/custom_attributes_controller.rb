class InstanceAdmin::Manage::CustomAttributesController < InstanceAdmin::Manage::BaseController

  before_filter :find_target
  before_filter :normalize_valid_values, only: [:create, :update]

  def index
    @custom_attributes = @target.custom_attributes.order('internal, name')
  end

  def new
    unless @custom_attribute = @target.custom_attributes.build
      flash[:error] = t 'flash_messages.instance_admin.manage.custom_attributes.invalid'
      redirect_to redirection_path
    end
  end

  def edit
    @custom_attribute = @target.custom_attributes.listable.find(params[:id])
  end

  def create
    @custom_attribute = @target.custom_attributes.build(custom_attributes_params)
    if @custom_attribute.save
      flash[:success] = t 'flash_messages.instance_admin.manage.custom_attributes.created'
      redirect_to redirection_path
    else
      flash[:error] = @custom_attribute.errors.full_messages.to_sentence
      render action: :new
    end
  end

  def update
    @custom_attribute = @target.custom_attributes.find(params[:id])
    if @custom_attribute.update_attributes(custom_attributes_params(@custom_attribute.required_internally?))
      flash[:success] = t 'flash_messages.instance_admin.manage.custom_attributes.updated'
      redirect_to redirection_path
    else
      flash[:error] = @custom_attribute.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    @custom_attribute = @target.custom_attributes.not_internal.find(params[:id])
    @custom_attribute.destroy
    flash[:success] = t 'flash_messages.instance_admin.manage.custom_attributes.deleted'
    redirect_to redirection_path
  end

  protected

  def redirection_path
    raise NotImplementedError
  end

  def find_target
    raise NotImplementedError
  end

  def normalize_valid_values
      params[:custom_attribute][:valid_values] = params[:custom_attribute][:valid_values].split(',').map(&:strip) if params[:custom_attribute] && params[:custom_attribute][:valid_values]
  end

  def custom_attributes_params(required_internally = false)

    pemitted_params = case required_internally
                      when true
                        secured_params.custom_attribute_internal
                      when false
                        secured_params.custom_attribute
                      else
                        raise NotImplementedError
                      end
    params.require(:custom_attribute).permit(pemitted_params).tap do |whitelisted|
      whitelisted[:wrapper_html_options] = params[:custom_attribute][:wrapper_html_options] if params[:custom_attribute] && params[:custom_attribute][:wrapper_html_options]
    end
  end

  def permitting_controller_class
    'manage'
  end
end
