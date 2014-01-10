# Update user info via social authentication
class UpdateInfoJob < Job

  def initialize(authentication)
    @authentication = authentication
    @user = @authentication.user
  end

  def perform
    return if not DesksnearMe::Application.config.perform_social_jobs
    Authentication::InfoUpdater.new(@authentication).update
  end

end
