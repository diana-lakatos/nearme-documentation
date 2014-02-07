class PlatformHomeController < ActionController::Base
  protect_from_forgery
  layout 'platform_home'

  def index
  end

  def features
  end

  def contact
    @platform_contact = PlatformContact.new
  end

  def contact_submit
    PlatformContact.create(params[:platform_contact])
    render :contact_submit, layout: false
  end

  def demo_request
    @platform_demo_request = PlatformDemoRequest.new
  end

  def demo_request_submit
    PlatformDemoRequest.create(params[:platform_demo_request])
    render :demo_request_submit, layout: false
  end

end
