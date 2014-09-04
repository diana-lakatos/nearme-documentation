class InstanceAdmin::Manage::WaiverAgreementTemplatesController < InstanceAdmin::Manage::BaseController

  def index
    @waiver_agreement_template = WaiverAgreementTemplate.first || WaiverAgreementTemplate.new
  end

  def create
    if (@waiver_agreement_template = WaiverAgreementTemplate.first).present?
      flash[:warning] = t 'flash_messages.instance_admin.manage.waiver_agreement_templates.already_created'
      render :index
    else
      @waiver_agreement_template = WaiverAgreementTemplate.new(waiver_agreement_template_params)
      @waiver_agreement_template.target = PlatformContext.current.instance
      if @waiver_agreement_template.save
        flash[:success] = t 'flash_messages.instance_admin.manage.waiver_agreement_templates.created'
        redirect_to action: :index
      else
        flash[:error] = @waiver_agreement_template.errors.full_messages.to_sentence
        render eindex
      end
    end
  end

  def update
    @waiver_agreement_template = WaiverAgreementTemplate.find(params[:id])
    if @waiver_agreement_template.update_attributes(waiver_agreement_template_params)
      flash[:success] = t 'flash_messages.instance_admin.manage.waiver_agreement_templates.updated'
      redirect_to action: :index
    else
      flash[:error] = @waiver_agreement_template.errors.full_messages.to_sentence
      render :index
    end
  end

  def destroy
    @waiver_agreement_template = WaiverAgreementTemplate.find(params[:id])
    @waiver_agreement_template.destroy
    flash[:deleted] = t 'flash_messages.instance_admin.manage.waiver_agreement_templates.deleted'
    redirect_to action: :index
  end

  private

  def waiver_agreement_template_params
    params.require(:waiver_agreement_template).permit(secured_params.waiver_agreement_template)
  end
end
