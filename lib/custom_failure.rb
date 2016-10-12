class CustomFailure < Devise::FailureApp
  def redirect_url
    return super unless [:user].include?(scope) # make it specific to a scope
    platform_context = PlatformContext.new(request.host)
    constraint = Rails.application.config.secure_app ? platform_context.secured_constraint : {}
    new_user_session_url(constraint.merge(return_to: request.original_url))
  end

  # You need to override respond to eliminate recall
  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end
end
