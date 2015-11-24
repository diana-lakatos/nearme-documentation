class OmniAuthCoercionService
  attr_accessor :name, :email, :expires_at, :token, :secret, :external_id

  def initialize(omniauth)
    @omniauth = omniauth
    execute_coercions
  end

  private
    def execute_coercions
      self.name = coerce_name
      self.email = coerce_email
      self.expires_at = coerce_expires_at
      self.token = coerce_token
      self.secret = coerce_secret
      self.external_id = coerce_external_id
    end

    def raw_info
      @raw_info ||= @omniauth['extra'] && @omniauth['extra']['raw_info']
    end

    def coerce_name
      @omniauth['info']['name'].presence ||
        "#{@omniauth['info']['first_name']} #{@omniauth['info']['last_name']}".presence ||
        "#{@omniauth['info']['First_name']} #{@omniauth['info']['Last_name']}".presence ||
        [raw_info.try(:[], 'First_name'), raw_info.try(:[], 'Last_name')].join(" ")
    end

    def coerce_email
      @omniauth['info']['email'].presence ||
        @omniauth['extra'] && @omniauth['extra']['raw_info'] && @omniauth['extra']['raw_info']['email_address']
    end

    def coerce_expires_at
      @omniauth['credentials'] && @omniauth['credentials']['expires_at'] ? Time.at(@omniauth['credentials']['expires_at']) : nil
    end

    def coerce_token
      (@omniauth['credentials'] && @omniauth['credentials']['token']).presence ||
        (raw_info && (raw_info['enterprise_id'].presence || raw_info['CustID']))
    end

    def coerce_secret
      @omniauth['credentials'] && @omniauth['credentials']['secret']
    end

    def coerce_external_id
      self.external_id ||= @omniauth['uid'] if PlatformContext.current.instance.is_community?
    end
end
