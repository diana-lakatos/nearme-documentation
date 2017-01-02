require 'google_plus'

class Authentication::GoogleProvider < Authentication::BaseProvider
  META   = { name: 'Google',
             url: 'http://google.com/',
             auth: 'OAuth 2' }

  def friend_ids
    @friend_ids ||= GooglePlus::Person.list('me', 'visible', max_results: 100, access_token: token).items.try(:map, &:id) || []
  rescue Exception => e
    @friend_ids = []
  end

  def info
    @info ||= Info.new(GooglePlus::Person.get('me', access_token: token).attributes)
  end

  class Info < BaseInfo
    def initialize(raw)
      @raw          = raw
      @uid          = raw['id'].presence
      @email        = raw['emails'].first['value']
      @name         = raw['display_name']
      @first_name   = raw['name']['givenName']
      @last_name    = raw['name']['familyName']
      @description  = raw['bio']
      @image_url    = raw['image']['url']
      @profile_url  = raw['url']
      @verified     = raw['verified']
      @provider     = 'Google'
    end
  end
end
