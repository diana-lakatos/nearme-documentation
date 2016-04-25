# Find friends via social authentication
class FindFriendsJob < Job
  def after_initialize(authentication)
    @authentication = authentication
    @user = authentication.user
  end

  def perform
    if DesksnearMe::Application.config.perform_social_jobs
      PlatformContext.current ||= PlatformContext.new(@authentication.instance)
      # We check with reload after setting the platform context as in rare circumstances the user is not
      # retrievable
      User::FriendFinder.new(@user, @authentication).find_friends! if !@authentication.reload.user.nil?
    end
  end
end
