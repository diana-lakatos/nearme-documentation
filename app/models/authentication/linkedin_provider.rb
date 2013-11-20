class Authentication::LinkedinProvider < Authentication::BaseProvider
  def connection
    @connection ||= LinkedIn::Client.new.tap{|c| c.set_access_token(token)}
  end

  def friend_ids
    begin
      @friend_ids ||= connection.connections.all.collect(&:id)
    rescue LinkedIn::Errors::AccessDeniedError
      raise ::Authentication::InvalidToken
    end
  end
end
