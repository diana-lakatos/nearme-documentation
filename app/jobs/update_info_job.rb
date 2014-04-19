# Update user info via social authentication
class UpdateInfoJob < Job

  def after_initialize(authentication)
    @authentication = authentication
  end

  def perform
    return if not DesksnearMe::Application.config.perform_social_jobs
    Authentication::InfoUpdater.new(@authentication).update
  rescue Authentication::InvalidToken
    @authentication.expire_token! if @authentication.token_expires?
  end

end
