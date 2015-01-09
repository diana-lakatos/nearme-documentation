class Admin::InstancesController < Admin::ResourceController
  before_filter lambda { PlatformContext.current = PlatformContext.new(Instance.find(params[:id])) }, :only => [:edit, :update, :destroy, :show]

  private

  def instance_params
    params.require(:instance).permit(secured_params.instance)
  end

end
