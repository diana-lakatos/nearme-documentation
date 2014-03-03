class InstanceAdmin::Manage::EmailTemplatesController < InstanceAdmin::Manage::BaseController

  def index
    @email_templates = platform_context.theme.email_templates
  end

  def edit
    @email_template = platform_context.theme.email_templates.first
  end

  def update
    @email_template = EmailTemplate.find(params[:id])

    if @email_template.update_attributes(params[:email_template])
      flash[:success] = 'Email template has been updated.'
      redirect_to action: :index
    else
      flash[:success] = 'An error was encountered, please try again.'
      render :edit
    end
  end

  def destroy
    @email_template = EmailTemplate.find(params[:id])
    @email_template.destroy

    flash[:success] = 'Email template has been deleted.'
    redirect_to action: :index
  end
end
