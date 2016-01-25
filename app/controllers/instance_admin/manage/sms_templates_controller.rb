class InstanceAdmin::Manage::SmsTemplatesController < InstanceAdmin::Manage::BaseController
  before_filter :find_transactable_type, only: [:create, :update]

  def index
    @sms_templates = platform_context.instance.instance_views.custom_smses
    @not_customized_sms_templates_paths = InstanceView.not_customized_sms_templates_paths
  end

  def new
    if params[:path] && InstanceView::DEFAULT_SMS_TEMPLATES_PATHS.include?(params[:path])
      @body = File.read(File.join(Rails.root, 'app', 'views', "#{params[:path]}.text.liquid"))
    else
      @body = ''
    end
    @sms_template = platform_context.instance.instance_views.build(path: params[:path], format: params[:sms_format], body: @body)
  end

  def edit
    @sms_template = platform_context.instance.instance_views.custom_smses.find(params[:id])
  end

  def create
    @sms_template = platform_context.instance.instance_views.build(template_params)
    @sms_template.format = 'text'
    @sms_template.handler = 'liquid'
    @sms_template.view_type = InstanceView::SMS_VIEW
    @sms_template.partial = false
    if @sms_template.save
      flash[:success] = t 'flash_messages.instance_admin.manage.sms_templates.created'
      redirect_to action: :index
    else
      flash.now[:error] = @sms_template.errors.full_messages.to_sentence
      render action: :new
    end
  end

  def update
    @sms_template = platform_context.instance.instance_views.custom_smses.find(params[:id])
    # do not allow to change path if it is in use
    if WorkflowAlert.for_sms_path(@sms_template.path).count > 0
      params[:sms_template][:path] = @sms_template.path
    end

    if @sms_template.update_attributes(template_params)
      flash[:success] = t 'flash_messages.instance_admin.manage.sms_templates.updated'
      redirect_to action: :index
    else
      flash.now[:error] = @sms_template.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    @sms_template = platform_context.instance.instance_views.custom_smses.find(params[:id])
    if WorkflowAlert.for_sms_path(@sms_template.path).count.zero?
      @sms_template.destroy
      flash[:success] = t 'flash_messages.instance_admin.manage.sms_templates.deleted'
    else
      flash[:error] = t 'flash_messages.instance_admin.manage.sms_templates.cannot_be_deleted'
    end
    redirect_to action: :index
  end

  private

  def template_params
    params.require(:sms_template).permit(secured_params.sms_template)
  end

  def find_transactable_type
    @transactable_type = TransactableType.find(params[:sms_template][:transactable_type_id]) if params[:sms_template][:transactable_type_id].present? rescue nil
  end
end

