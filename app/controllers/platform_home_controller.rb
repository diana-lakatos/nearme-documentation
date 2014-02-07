class PlatformHomeController < ActionController::Base
  protect_from_forgery
  layout 'platform_home'

  def index
  end

  def features
  end

  def contact
    @platform_inquiry = PlatformInquiry.new
  end

  def demo_request
  end

end
