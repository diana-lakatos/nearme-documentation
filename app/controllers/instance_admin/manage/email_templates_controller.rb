class InstanceAdmin::Manage::EmailTemplatesController < InstanceAdmin::Manage::BaseController

  def index
    @email_templates = platform_context.theme.email_templates
  end

  def new
    @email_template = EmailTemplate.new(path: params[:path])
  end

  def edit
    @email_template = platform_context.theme.email_templates.find(params[:id])
  end

  def create
    @email_template = EmailTemplate.new(params[:email_template])
    @email_template.theme = platform_context.theme
    if @email_template.save
      redirect_to action: :index
    else
      flash[:error] = @email_template.errors.full_messages.to_sentence
      render action: :new
    end
  end

  def update
    @email_template = platform_context.theme.email_templates.find(params[:id])

    if @email_template.update_attributes(params[:email_template])
      flash[:success] = 'Email template has been updated.'
      redirect_to action: :index
    else
      flash[:success] = 'An error was encountered, please try again.'
      render :edit
    end
  end

  def destroy
    @email_template = platform_context.theme.email_templates.find(params[:id])
    @email_template.destroy

    flash[:success] = 'Email template has been deleted.'
    redirect_to action: :index
  end
end
