class InstanceAdmin::Manage::EmailLayoutTemplatesController < InstanceAdmin::Manage::BaseController
  before_filter :find_transactable_type, only: [:create, :update]

  def index
    @email_layout_templates = platform_context.instance.instance_views.custom_email_layouts.order('path')
    @not_customized_email_template_layouts_paths = InstanceView.not_customized_email_template_layouts_paths
  end

  def new
    if params[:path] && InstanceView::DEFAULT_EMAIL_TEMPLATE_LAYOUTS_PATHS.include?(params[:path]) && %w(html text).include?(params[:email_format])
      @body = File.read(File.join(Rails.root, 'app', 'views', "#{params[:path]}.#{params[:email_format]}.liquid"))
    else
      @body = ''
    end
    @email_layout_template = platform_context.instance.instance_views.build(path: params[:path], format: params[:email_format], body: @body)
  end

  def edit
    @email_layout_template = platform_context.instance.instance_views.custom_email_layouts.find(params[:id])
  end

  def create
    @email_layout_template = platform_context.instance.instance_views.build(template_params)
    @email_layout_template.handler = 'liquid'
    @email_layout_template.view_type = InstanceView::EMAIL_LAYOUT_VIEW
    @email_layout_template.partial = false
    if @email_layout_template.save
      flash[:success] = t 'flash_messages.instance_admin.manage.email_layout_templates.created'
      redirect_to action: :index
    else
      flash.now[:error] = @email_layout_template.errors.full_messages.to_sentence
      render action: :new
    end
  end

  def update
    @email_layout_template = platform_context.instance.instance_views.custom_email_layouts.find(params[:id])
    # do not allow to change path if it is in use
    if WorkflowAlert.for_email_layout_path(@email_layout_template.path).count > 0
      params[:email_layout_template][:path] = @email_layout_template.path
    end

    if @email_layout_template.update_attributes(template_params)
      flash[:success] = t 'flash_messages.instance_admin.manage.email_layout_templates.updated'
      redirect_to action: :index
    else
      flash.now[:error] = @email_layout_template.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    @email_layout_template = platform_context.instance.instance_views.custom_email_layouts.find(params[:id])
    if WorkflowAlert.for_email_layout_path(@email_layout_template.path).count.zero?
      @email_layout_template.destroy
      flash[:success] = t 'flash_messages.instance_admin.manage.email_layout_templates.deleted'
    else
      flash[:error] = t 'flash_messages.instance_admin.manage.email_layout_templates.cannot_be_deleted'
    end
    redirect_to action: :index
  end

  private

  def template_params
    params.require(:email_layout_template).permit(secured_params.email_layout_template)
  end

  def find_transactable_type
    @transactable_type = TransactableType.find(params[:email_layout_template][:transactable_type_id]) if params[:email_layout_template][:transactable_type_id].present? rescue nil
  end
end
