class PlatformHomeController < ActionController::Base
  force_ssl if: :require_ssl?
  prepend_view_path InstanceViewResolver.instance

  protect_from_forgery
  layout 'platform_home'

  def index
    if params[:domain_not_valid]
      flash[:error] = 'This domain has not been configured.'
      redirect_to '/'
    end
    @platform_contact = PlatformContact.new
  end

  def require_ssl?
    Rails.application.config.secure_app && !request.ssl?
  end

  def contact
    @platform_contact = PlatformContact.new
  end

  def contact_submit
    @platform_contact = PlatformContact.new(platform_contact_params)
    @platform_contact.referer = request.referer
    if verified_request? && @platform_contact.save
      PlatformMailer.enqueue.contact_request(@platform_contact)
      PlatformMailer.enqueue.email_notification(@platform_contact.email)
      render :contact_submit, layout: false
    else
      @platform_contact.errors.add(:CSRF_token, 'is invalid') if !verified_request?
      render text: @platform_contact.errors.full_messages.to_sentence, layout: false, :status => :unprocessable_entity
    end
  end

  def contacts
    @platform_contacts = PlatformContact.order(:id)
    respond_to do |format|
      format.csv { send_data @platform_contacts.to_csv }
    end
  end

  def demo_requests
    @platform_demo_requests = PlatformDemoRequest.order(:id)
    respond_to do |format|
      format.csv { send_data @platform_demo_requests.to_csv }
    end
  end

  def unsubscribe
    verifier = ActiveSupport::MessageVerifier.new(DesksnearMe::Application.config.secret_token)
    email_address = verifier.verify(params[:unsubscribe_key])
    @email = PlatformEmail.where('email = ?', email_address).first

    if @email
      @resubscribe_url = platform_email_resubscribe_url(params[:unsubscribe_key])
      @email.unsubscribe!
    else
      redirect_to '/'
    end
  end

  def resubscribe
    verifier = ActiveSupport::MessageVerifier.new(DesksnearMe::Application.config.secret_token)
    email_address = verifier.verify(params[:resubscribe_key])
    @email = PlatformEmail.where('email = ?', email_address).first

    if @email
      @email.resubscribe!
    else
      redirect_to '/'
    end
  end

  private

  def platform_contact_params
    params.require(:platform_contact).permit([:name, :email, :subject, :comments,
      :subscribed, :company, :marketplace_type, :location, :phone, :previous_research, :lead_source])
  end
end
