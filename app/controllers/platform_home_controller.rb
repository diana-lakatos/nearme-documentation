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

end
