class Authentication::TwitterProvider < Authentication::BaseProvider
  def connection
    @connection ||= ::Twitter::Client.new(oauth_token: token, oauth_token_secret: secret)
  end

  def friend_ids
    begin
      @friend_ids ||= connection.friends.all.collect{ |f| f.attrs[:id_str] }
    rescue Twitter::Error::Unauthorized
      raise ::Authentication::InvalidToken
    end
  end
end
