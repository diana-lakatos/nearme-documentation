# Prepare FindFriendsJobs
class PrepareFriendFindersJob < Job
  def perform
    Authentication.with_valid_token.each do |auth|
      PlatformContext.current = PlatformContext.new(auth.instance)
      FindFriendsJob.perform(auth)
    end
  end
end
