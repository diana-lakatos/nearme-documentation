class PlatformHomeController < ActionController::Base
  protect_from_forgery
  layout 'platform_home'

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

  def unsubscribe
    verifier = ActiveSupport::MessageVerifier.new(DesksnearMe::Application.config.secret_token)
    email_address = verifier.verify(params[:unsubscribe_key])
    @email = PlatformEmail.where('email = ?', email_address).first

    if @email
      @resubscribe_url = platform_email_resubscribe_url(params[:unsubscribe_key])
      @email.unsubscribe!
    else
      redirect '/'
    end
  end

  def resubscribe
    verifier = ActiveSupport::MessageVerifier.new(DesksnearMe::Application.config.secret_token)
    email_address = verifier.verify(params[:resubscribe_key])
    @email = PlatformEmail.where('email = ?', email_address).first

    if @email
      @email.resubscribe!
    else
      redirect '/'
    end
  end
end
