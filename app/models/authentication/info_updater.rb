class Authentication::InfoUpdater

  attr_accessor :authentication, :user, :authentication_changes, :user_changes

  def initialize(authentication)
    @authentication = authentication
    @user = authentication.user
    @provider = authentication.social_connection
  end

  def update
    info = @provider.info
    info_hash = info.hash

    @authentication.info = info_hash
    @authentication.profile_url = info.profile_url
    @authentication_changes = @authentication.changes
    @authentication.save!

    @user.name ||= info_hash['name']
    @user.biography ||= info_hash['description']
    @user.current_location ||= info_hash['location']
    @user.country_name ||= Geocoder.search(info_hash['location']).first.country rescue nil

    if !@user.avatar.any_url_exists? && info_hash['image'].present?
      @user.avatar_versions_generated_at = Time.zone.now
      @user.remote_avatar_url = info_hash['image']
    end
    @user_changes = @user.changes.inspect
    @user.save!

    self
  end

end
