# Find friends via social authentication
class FindFriendsJob < Job
  def initialize(authentication)
    @authentication = authentication
    @user = authentication.user
  end

  def perform
    User::FriendFinder.new(@user, @authentication).find_friends!
  end
end
