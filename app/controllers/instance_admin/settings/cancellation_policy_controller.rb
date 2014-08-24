class InstanceAdmin::Settings::CancellationPolicyController < InstanceAdmin::Settings::BaseController

  before_filter :find_transactable_type

  def show
  end

  def update
    if @transactable_type.update_attributes(transactable_type_params)
      flash.now[:success] = t('flash_messages.instance_admin.settings.settings_updated')
      render :show
    else
      flash.now[:error] = @transactable_type.errors.full_messages.to_sentence
      render :show
    end
  end

  private

  def find_transactable_type
    @transactable_type = TransactableType.first
  end

  def transactable_type_params
    params.require(:transactable_type).permit(secured_params.transactable_type)
  end
end
