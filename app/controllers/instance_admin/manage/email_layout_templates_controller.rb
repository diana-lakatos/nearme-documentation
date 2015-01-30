class InstanceAdmin::Manage::EmailLayoutTemplatesController < InstanceAdmin::Manage::BaseController

  def index
    @email_layout_templates = platform_context.instance.instance_views.custom_email_layouts.order('path')
  end

  def new
    @email_layout_template = platform_context.instance.instance_views.build
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
      flash[:error] = @email_layout_template.errors.full_messages.to_sentence
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
      flash[:error] = @email_layout_template.errors.full_messages.to_sentence
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

end

