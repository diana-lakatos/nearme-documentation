class PlatformHomeController < ActionController::Base
  layout 'platform_home'

  def index
  end

  def notify_me
    email = PlatformEmail.create(email: params[:email])
    if email.errors.added?(:email, email.errors.generate_message(:email, :taken))
      render :duplicate_email, layout: false
    else
      render :notify_me, layout: false
    end
  end

  def get_in_touch
    @map_background = true
  end

  def save_inquiry
    inquiry_params = Rack::Utils.parse_nested_query(params[:inquiry])
    @inquiry = PlatformInquiry.create(inquiry_params['inquiry'])

    render json: { body: render_to_string(:save_inquiry, layout: false), status: @inquiry.persisted?, locals: @inquiry.persisted? }.to_json
  end

  def send_email
    from_name = params[:email_data][:your_name].to_s.gsub(%r{</?[^>]+?>}, '')
    params[:email_data][:emails].to_s.split(',').each do |email|
      email.strip!
      next if email !~ PlatformEmail::EMAIL_VALIDATOR
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
      @resubscribe_url = "/resubscribe/#{params[:unsubscribe_key]}"
      @email.unsubscribe!

      render :unsubscribe
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

      render :resubscribe
    else
      redirect '/'
    end
  end
end
