class Authentication::BaseProvider
  attr_accessor :auth, :user, :token, :secret

  def initialize(auth)
    self.auth = auth
    self.user = auth.user
    self.token = auth.token
    self.secret = auth.secret
  end

  def connection
    raise NotImplementedError
  end

  def provider
    raise NotImplementedError
  end

  def friend_ids
    raise NotImplementedError
  end

  def connections
    @connections = User.joins(:authentications).where(authentications: {uid: self.friend_ids, provider: provider})
  end

  def new_connections
    @new_connections = connections.without(user.friends)
  end
end
