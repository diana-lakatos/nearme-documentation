# Find friends via social authentication
class FindFriendsJob < Job
  def after_initialize(authentication_id)
    @authentication = Authentication.find(authentication_id)
    @user = @authentication.user
  end

  def perform
    return unless DesksnearMe::Application.config.perform_social_jobs
    return unless @user

    PlatformContext.current ||= PlatformContext.new(@authentication.instance)
    User::FriendFinder.new(@user, @authentication).find_friends!
  end
end
