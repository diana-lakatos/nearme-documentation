class Authentication::TwitterProvider < Authentication::BaseProvider

  def connection
    @connection ||= Twitter::REST::Client.new(access_token: token, access_token_secret: secret,consumer_key: DesksnearMe::Application.config.twitter_key, consumer_secret: DesksnearMe::Application.config.twitter_secret)
  end

  def friend_ids
    begin
      @friend_ids ||= connection.friend_ids(count: 5000, stringify_ids: true).to_a
    rescue Twitter::Error::Unauthorized
      raise ::Authentication::InvalidToken
    rescue Twitter::Error::TooManyRequests
      Rails.logger.info "ignored friend_ids for #{@user.id} #{@user.name} due to Rate Limit Exceeded error"
    end
  end
end
