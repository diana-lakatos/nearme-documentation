class Authentication::FacebookProvider < Authentication::BaseProvider
  def connection
    @connection ||= Koala::Facebook::API.new(token)
  end

  def friend_ids
    @friend_ids = connection.get_connections("me", "friends").collect{ |f| f["id"].to_s }
  end
end
