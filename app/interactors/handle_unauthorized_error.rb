# frozen_string_literal: true
class HandleUnauthorizedError
  def initialize(controller:, error:)
    @controller = controller
    @error = error
  end

  def run
    # here we can add advanced features in the future - render custom page, redirect to url etc
    @controller.send :head, :forbidden
  end

  protected

  def unauthorized_policy
    @error.unauthorized_policy
  end
end
