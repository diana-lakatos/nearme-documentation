class InstanceAdmin::Manage::SearchController < InstanceAdmin::Manage::BaseController
  before_filter :find_instance

  def show
    @transactable_types = TransactableType.by_position
  end

  def update
    @instance.update_attributes(instance_params)
    if @instance.save
      flash[:success] = t('flash_messages.search.setting_saved')
      redirect_to action: :show
    else
      flash[:error] = @instance.errors.full_messages.to_sentence
      redirect_to action: :show
    end
  end

  def sort_transactable_types
    TransactableType.searchable.each do |tt|
      tt.update_column(:position, params[:transactable_types].index("tt_#{tt.id}"))
    end
    render nothing: true
  end

  private

  def permitting_controller_class
    self.class.to_s.deconstantize.deconstantize.demodulize
  end

  def find_instance
    @instance = platform_context.instance
  end

  def instance_params
    params.require(:instance).permit(secured_params.instance)
  end
end
