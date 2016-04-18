# Prepare FindFriendsJobs
class PrepareFriendFindersJob < Job
  def perform
    Authentication.with_valid_token.each do |authentication|
      FindFriendsJob.perform(authentication.id)
    end
  end
end
