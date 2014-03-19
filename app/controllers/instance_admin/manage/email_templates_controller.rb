class InstanceAdmin::Manage::EmailTemplatesController < InstanceAdmin::Manage::BaseController

  def index
    @email_templates = platform_context.theme.email_templates
  end

  def new
    unless @email_template = EmailTemplate.new_from_file_template(params[:path])
      flash[:error] = t 'flash_messages.instance_admin.manage.email_templates.invalid'
      redirect_to action: :index
    end
  end

  def edit
    @email_template = platform_context.theme.email_templates.find(params[:id])
  end

  def create
    @email_template = EmailTemplate.new(params[:email_template])
    @email_template.theme = platform_context.theme
    if @email_template.save
      flash[:success] = t 'flash_messages.instance_admin.manage.email_templates.created'
      redirect_to action: :index
    else
      flash[:error] = @email_template.errors.full_messages.to_sentence
      render action: :new
    end
  end

  def update
    @email_template = platform_context.theme.email_templates.find(params[:id])

    if @email_template.update_attributes(params[:email_template])
      flash[:success] = t 'flash_messages.instance_admin.manage.email_templates.updated'
      redirect_to action: :index
    else
      flash[:error] = @email_template.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    @email_template = platform_context.theme.email_templates.find(params[:id])
    @email_template.destroy

    flash[:success] = t 'flash_messages.instance_admin.manage.email_templates.deleted'
    redirect_to action: :index
  end
end
