class Authentication::LinkedinProvider < Authentication::BaseProvider
  def connection
    @connection ||= LinkedIn::Client.new.tap{|c| c.set_access_token(token)}
  end

  def friend_ids
    @friend_ids = connection.connections.all.collect(&:id)
  end
end
