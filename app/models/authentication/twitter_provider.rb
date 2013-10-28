class Authentication::TwitterProvider < Authentication::BaseProvider
  def connection
    @connection ||= ::Twitter::Client.new(oauth_token: token, oauth_token_secret: secret)
  end

  def friend_ids
    @friend_ids = connection.friends.all.collect{ |f| f.attrs[:id_str] }
  end
end
