class Authentication::InfoUpdater

  attr_accessor :authentication, :user, :authentication_changes, :user_changes

  def initialize(authentication)
    @authentication = authentication
    @user = authentication.user
    @provider = authentication.social_connection
  end

  def update
    return if @provider.nil?
    return if @authentication.token_expired?
    info = @provider.info
    info_hash = info.to_hash

    @authentication.info = info_hash
    @authentication.profile_url = info.profile_url
    @authentication_changes = @authentication.changes
    @authentication.instance_id ||= (PlatformContext.current.try(:instance).try(:id).presence || PlatformContext.new.instance.id)
    @authentication.save!

    @user.name ||= info_hash['name']
    @user.current_location ||= info_hash['location']
    @user.country_name ||= Geocoder.search(info_hash['location']).first.country rescue nil

    if !@user.attributes['avatar'] && info_hash['image'].present?
      @user.avatar_versions_generated_at = Time.zone.now
      @user.remote_avatar_url = info_hash['image']
    end
    @user_changes = @user.changes.inspect
    @user.save!
    @authentication.touch(:information_fetched)

    self
  end

end
