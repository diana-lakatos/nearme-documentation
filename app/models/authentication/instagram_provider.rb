class Authentication::InstagramProvider < Authentication::BaseProvider

  KEY    = DesksnearMe::Application.config.instagram_key
  SECRET = DesksnearMe::Application.config.instagram_secret

  def friend_ids
    []
  end

end
