class Admin::InstancesController < Admin::ResourceController
  before_filter lambda { PlatformContext.current = PlatformContext.new(Instance.find(params[:id])) }, :only => [:edit, :update, :destroy, :show]
  before_filter :normalize_required_fields, only: [:create, :update]

  private

  def instance_params
    params.require(:instance).permit(secured_params.instance)
  end

  def normalize_required_fields
    params[:instance][:user_required_fields] = params[:instance][:user_required_fields].split(',').map(&:strip).reject(&:blank?)
  end

end
