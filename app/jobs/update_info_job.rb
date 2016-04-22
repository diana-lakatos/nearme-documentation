# Update user info via social authentication
class UpdateInfoJob < Job
  def after_initialize(authentication_id)
    @authentication = Authentication.find(authentication_id)
  end

  def perform
    return unless DesksnearMe::Application.config.perform_social_jobs

    Authentication::InfoUpdater.new(@authentication).update
  rescue Authentication::InvalidToken
    @authentication.expire_token! if @authentication.token_expires?
  end
end
