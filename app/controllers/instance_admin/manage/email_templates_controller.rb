class InstanceAdmin::Manage::EmailTemplatesController < InstanceAdmin::Manage::BaseController
  before_filter :find_transactable_type, only: [:create, :update]

  def index
    @email_templates = platform_context.instance.instance_views.custom_emails.order('path')
    @not_customized_email_templates_paths = InstanceView.not_customized_email_templates_paths
  end

  def new
    if params[:path] && InstanceView::DEFAULT_EMAIL_TEMPLATES_PATHS.include?(params[:path]) && %w(html text).include?(params[:email_format])
      @body = File.read(File.join(Rails.root, 'app', 'views', "#{params[:path]}.#{params[:email_format]}.liquid"))
    else
      @body = ''
    end
    @email_template = platform_context.instance.instance_views.build(path: params[:path], format: params[:email_format], body: @body)
  end

  def edit
    @email_template = platform_context.instance.instance_views.custom_emails.find(params[:id])
  end

  def create
    @email_template = platform_context.instance.instance_views.build(template_params)
    @email_template.handler = 'liquid'
    @email_template.view_type = InstanceView::EMAIL_VIEW
    @email_template.partial = false
    if @email_template.save
      flash[:success] = t 'flash_messages.instance_admin.manage.email_templates.created'
      redirect_to action: :index
    else
      flash.now[:error] = @email_template.errors.full_messages.to_sentence
      render action: :new
    end
  end

  def update
    @email_template = platform_context.instance.instance_views.custom_emails.find(params[:id])
    # do not allow to change path if it is in use
    if WorkflowAlert.for_email_path(@email_template.path).count > 0
      params[:email_template][:path] = @email_template.path
    end

    if @email_template.update_attributes(template_params)
      flash[:success] = t 'flash_messages.instance_admin.manage.email_templates.updated'
      redirect_to action: :index
    else
      flash.now[:error] = @email_template.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    @email_template = platform_context.instance.instance_views.custom_emails.find(params[:id])
    if WorkflowAlert.for_email_path(@email_template.path).count.zero?
      @email_template.destroy
      flash[:success] = t 'flash_messages.instance_admin.manage.email_templates.deleted'
    else
      flash[:error] = t 'flash_messages.instance_admin.manage.email_templates.cannot_be_deleted'
    end
    redirect_to action: :index
  end

  private

  def template_params
    params.require(:email_template).permit(secured_params.email_template)
  end

  def find_transactable_type
    @transactable_type = TransactableType.find(params[:email_template][:transactable_type_id]) if params[:email_template][:transactable_type_id].present? rescue nil
  end

end

