class InstanceAdmin::Manage::WaiverAgreementTemplatesController < InstanceAdmin::Manage::BaseController
  def index
    # scoping to instance is not duplicating <autoscope to platform context>. We have polymorphic association here, we want
    # to get only waiver agreement templates where target_type is Instance, not where instance_id = X
    @waiver_agreement_template = PlatformContext.current.instance.waiver_agreement_templates.first || WaiverAgreementTemplate.new
  end

  def create
    if (@waiver_agreement_template = PlatformContext.current.instance.waiver_agreement_templates.first).present?
      flash[:warning] = t 'flash_messages.instance_admin.manage.waiver_agreement_templates.already_created'
      render :index
    else
      @waiver_agreement_template = PlatformContext.current.instance.waiver_agreement_templates.build(waiver_agreement_template_params)
      @waiver_agreement_template.target = PlatformContext.current.instance
      if @waiver_agreement_template.save
        flash[:success] = t 'flash_messages.instance_admin.manage.waiver_agreement_templates.created'
        redirect_to action: :index
      else
        flash[:error] = @waiver_agreement_template.errors.full_messages.to_sentence
        render :index
      end
    end
  end

  def update
    @waiver_agreement_template = PlatformContext.current.instance.waiver_agreement_templates.find(params[:id])
    if @waiver_agreement_template.update_attributes(waiver_agreement_template_params)
      flash[:success] = t 'flash_messages.instance_admin.manage.waiver_agreement_templates.updated'
      redirect_to action: :index
    else
      flash[:error] = @waiver_agreement_template.errors.full_messages.to_sentence
      render :index
    end
  end

  def destroy
    @waiver_agreement_template = PlatformContext.current.instance.waiver_agreement_templates.find(params[:id])
    @waiver_agreement_template.destroy
    flash[:deleted] = t 'flash_messages.instance_admin.manage.waiver_agreement_templates.deleted'
    redirect_to action: :index
  end

  private

  def waiver_agreement_template_params
    params.require(:waiver_agreement_template).permit(secured_params.waiver_agreement_template)
  end
end
