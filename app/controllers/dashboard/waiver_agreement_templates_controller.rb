class Dashboard::WaiverAgreementTemplatesController < Dashboard::BaseController

  def index
    @waiver_agreement_templates = @company.waiver_agreement_templates
  end

  def new
    @waiver_agreement_template = @company.waiver_agreement_templates.build
    @waiver_agreement_template.content = PlatformContext.current.instance.waiver_agreement_templates.first.try(:content)
    render partial: "form"
  end

  def edit
    @waiver_agreement_template = @company.waiver_agreement_templates.find(params[:id])
    render partial: "form"
  end

  def create
    @waiver_agreement_template = @company.waiver_agreement_templates.build(waiver_agreement_template_params)
    if @waiver_agreement_template.save
      flash[:success] = t 'flash_messages.manage.waiver_agreement_templates.created'
      redirect_to_index
    else
      render partial: "form"
    end
  end

  def update
    @waiver_agreement_template = @company.waiver_agreement_templates.find(params[:id])
    if @waiver_agreement_template.update_attributes(waiver_agreement_template_params)
      flash[:success] = t 'flash_messages.manage.waiver_agreement_templates.updated'
      redirect_to_index
    else
      flash[:error] = view_context.array_to_unordered_list(@waiver_agreement_template.errors.full_messages)
      render partial: "form"
    end
  end

  def destroy
    @waiver_agreement_template = @company.waiver_agreement_templates.find(params[:id])
    @waiver_agreement_template.destroy
    flash[:success] = t 'flash_messages.manage.waiver_agreement_templates.deleted'
    redirect_to_index
  end

  private
  def redirect_to_index
    redirect_to dashboard_waiver_agreement_templates_url
    render_redirect_url_as_json if request.xhr?
  end

  def waiver_agreement_template_params
    params.require(:waiver_agreement_template).permit(secured_params.waiver_agreement_template)
  end
end
