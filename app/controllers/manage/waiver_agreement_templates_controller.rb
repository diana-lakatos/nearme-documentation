class Manage::WaiverAgreementTemplatesController < Manage::BaseController
  before_filter :find_company
  before_filter :redirect_if_no_company

  def index
    @waiver_agreement_templates = @company.waiver_agreement_templates
  end

  def new
    @waiver_agreement_template = @company.waiver_agreement_templates.build
    @waiver_agreement_template.content = PlatformContext.current.instance.waiver_agreement_templates.first.try(:content)
  end

  def edit
    @waiver_agreement_template = @company.waiver_agreement_templates.find(params[:id])
  end

  def create
    @waiver_agreement_template = @company.waiver_agreement_templates.build(waiver_agreement_template_params)
    if @waiver_agreement_template.save
      flash[:success] = t 'flash_messages.manage.waiver_agreement_templates.created'
      redirect_to action: :index
    else
      render :new
    end
  end

  def update
    @waiver_agreement_template = @company.waiver_agreement_templates.find(params[:id])
    if @waiver_agreement_template.update_attributes(waiver_agreement_template_params)
      flash[:success] = t 'flash_messages.manage.waiver_agreement_templates.updated'
      redirect_to action: :index
    else
      flash[:error] = @waiver_agreement_template.errors.full_messages.to_sentence
      render :index
    end
  end

  def destroy
    @waiver_agreement_template = @company.waiver_agreement_templates.find(params[:id])
    @waiver_agreement_template.destroy
    flash[:success] = t 'flash_messages.manage.waiver_agreement_templates.deleted'
    redirect_to action: :index
  end

  private

  def find_company
    @company = current_user.companies.first
  end

  def redirect_if_no_company
    unless @company
      flash[:warning] = t('flash_messages.dashboard.add_your_company')
      redirect_to new_space_wizard_url
    end
  end

  def waiver_agreement_template_params
    params.require(:waiver_agreement_template).permit(secured_params.waiver_agreement_template)
  end
end
