class InstanceAdmin::Theme::ContentHoldersController < InstanceAdmin::Theme::BaseController

  def index
  end

  def create
    @content_holder = PlatformContext.current.theme.content_holders.new(content_holder_params)
    @content_holder.instance = PlatformContext.current.instance
    create!
  end

  private

  def content_holder_params
    params.require(:content_holder).permit(secured_params.content_holder)
  end

end
