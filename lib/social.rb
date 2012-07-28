require "social/facebook"
require "social/twitter"
require "social/linkedin"

module Social
  def self.provider(provider)
    const_get(provider.titleize.to_sym)
  end

  # Returns the uid and info hash, same as omniauth
  def self.get_user_info(provider, token, secret = nil)
    provider = self.provider(provider)
    return [nil, nil] unless provider.present?
    provider.get_user_info(token, secret)
  end
end
