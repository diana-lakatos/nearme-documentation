# Find friends via social authentication
class FindFriendsJob < Job
  def after_initialize(authentication)
    @authentication = authentication
    @user = authentication.user
  end

  def perform
    if DesksnearMe::Application.config.perform_social_jobs
      PlatformContext.current ||= PlatformContext.new(@authentication.instance)
      User::FriendFinder.new(@user, @authentication).find_friends! unless @user.nil?
    end
  end
end
