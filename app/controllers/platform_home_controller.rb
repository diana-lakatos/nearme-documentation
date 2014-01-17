class PlatformHomeController < ActionController::Base
  protect_from_forgery
  layout 'platform_home'

  def index
    @platform_email = PlatformEmail.new
  end

  def notify_me
    email = PlatformEmail.create(params[:platform_email])
    if email.errors.added?(:email, email.errors.generate_message(:email, :taken))
      render :duplicate_email, layout: false
    else
      render :notify_me, layout: false
    end
  end

  def get_in_touch
    @map_background = true
    @platform_inquiry = PlatformInquiry.new
  end

  def save_inquiry
    @inquiry = PlatformInquiry.create(params['platform_inquiry'])

    render json: { body: render_to_string(:save_inquiry, layout: false), status: @inquiry.persisted?, locals: @inquiry.persisted? }.to_json
  end

  def send_email
    from_name = params[:email_data][:your_name].to_s.gsub(%r{</?[^>]+?>}, '')
    params[:email_data][:emails].to_s.split(',').each do |email|
      email.strip!
      PlatformMailer.email_a_friend(from_name, email).deliver
    end
    render :nothing => true, :status => 200, :content_type => 'text/html'
  end

  def unsubscribe
    verifier = ActiveSupport::MessageVerifier.new(DesksnearMe::Application.config.secret_token)
    email_address = verifier.verify(params[:unsubscribe_key])
    @email = PlatformEmail.where('email = ?', email_address).first

    if @email
      @light_background = true
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
      @light_background = true
      @email.resubscribe!
    else
      redirect '/'
    end
  end
end
