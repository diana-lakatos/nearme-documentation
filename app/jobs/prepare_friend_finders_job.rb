# Prepare FindFriendsJobs
class PrepareFriendFindersJob < Job
  def perform
    Authentication.with_valid_token.each do |auth|
      FindFriendsJob.perform(auth)
    end
  end
end
