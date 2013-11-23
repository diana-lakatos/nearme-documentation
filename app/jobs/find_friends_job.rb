# Find friends via social authentication
class FindFriendsJob < Job
  def initialize(authentication)
    @authentication = authentication
    @user = authentication.user
  end

  def perform
    if DesksnearMe::Application.config.perform_social_jobs
      User::FriendFinder.new(@user, @authentication).find_friends!
    end
  end
end
