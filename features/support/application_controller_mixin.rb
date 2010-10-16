module ApplicationControllerMixin
  # Lookup the current user in the ENV
  def current_user
    session[:user_id] = ENV.delete('CURRENT_USER_ID') if ENV['CURRENT_USER_ID']
    super
  end
end
