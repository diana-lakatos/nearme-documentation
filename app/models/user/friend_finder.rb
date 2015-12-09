class User::FriendFinder
  attr_accessor :user, :authentications

  def initialize(user, authentications)
    self.user = user
    self.authentications = Array.wrap(authentications)
  end

  def find_friends!
    authentications.each do |authentication|
      new_friends = []
      begin
        authentication.new_connections.each{|u| new_friends << u }
      rescue ::Authentication::InvalidToken
        authentication.expire_token!
        return false
      end

      # add friends
      if new_friends.present?
        new_friends.each do |new_friend|
          user.add_friend(new_friend, authentication)
        end

        # update total connections
        authentication.update_attribute(:total_social_connections, authentication.friend_ids.count)
      end
    end

    return true
  end
end
