class PlatformHomeController < ActionController::Base

  layout 'platform_home'

  def index

  end

  def get_in_touch
    @map_background = true
  end

end
