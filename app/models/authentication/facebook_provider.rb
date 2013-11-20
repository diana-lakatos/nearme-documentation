class Authentication::FacebookProvider < Authentication::BaseProvider
  def connection
    @connection ||= Koala::Facebook::API.new(token)
  end

  def friend_ids
    begin
      @friend_ids ||= connection.get_connections("me", "friends").collect{ |f| f["id"].to_s }
    rescue Koala::Facebook::AuthenticationError
      raise ::Authentication::InvalidToken
    end
  end
end
