module ApplicationControllerMixin

  # Lookup the current user in the ENV
  def current_user
    session[:user_id] = ENV.delete('CURRENT_USER_ID') if Rails.env.test? && ENV['CURRENT_USER_ID']
    super
  end

end
