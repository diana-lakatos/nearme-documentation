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
      new_friends.each do |new_friend|
        user.add_friend(new_friend, authentication)
      end
    end

    return true
  end
end
