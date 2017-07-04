# frozen_string_literal: true
class HandleUnauthorizedError
  def initialize(controller:, error:)
    @controller = controller
    @error = error
  end

  def run
    redirect || http_forbidden
  end

  private

  def unauthorized_policy
    @error.unauthorized_policy
  end

  def redirect
    return unless unauthorized_policy.redirect_to
    @controller.redirect_to redirect_path
  end

  def http_forbidden
    @controller.head :forbidden
  end

  def current_path
    @controller.request.fullpath
  end

  def redirect_path
    "#{unauthorized_policy.redirect_to}?return_to=#{current_path}"
  end
end
