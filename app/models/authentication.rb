class Authentication < ActiveRecord::Base
  class InvalidToken < Exception; end;
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :user
  belongs_to :instance

  has_many :user_relationships
  has_many :connections, through: :user_relationships, source: :follower, class_name: 'User'

  validates :provider, :uid, :token, presence: true
  validates :provider, uniqueness: { scope: [:instance_id, :user_id] }
  validates :uid,      uniqueness: { scope: [:instance_id, :provider, :deleted_at] }

  serialize :info, Hash

  delegate :new_connections, :friend_ids, to: :social_connection, allow_nil: true

  scope :with_valid_token, -> {
    where('authentications.token_expires_at > ? OR authentications.token_expires_at IS NULL', Time.now).
    where(token_expired: false)
  }

  after_create :find_friends
  after_create :update_info

  PROVIDERS = ["Facebook", "LinkedIn", "Twitter", "Instagram", "Google", "GitHub"]
  ALLOWED_LOGIN_PROVIDERS = PROVIDERS + ["SAML"] - ["Instagram"]

  def social_connection
    @social_connection ||= self.class.provider_class(provider).try(:new_from_authentication, self)
  end

  def self.available_providers
    PROVIDERS.select { |provider| PlatformContext.current.instance.authentication_supported?(provider) }
  end

  def self.available_login_providers
    providers = PROVIDERS.select { |provider| PlatformContext.current.instance.authentication_supported?(provider) }
    providers & ALLOWED_LOGIN_PROVIDERS
  end

  def self.provider(provider)
    provider_class(provider)
  end

  def self.provider_class(provider)
    "Authentication::#{provider.camelize}Provider".constantize
  end

  def connections_count
    self.connections.count
  end

  def can_be_deleted?
    # we can delete authentication if user has other option to log in, i.e. has set password or other authentications
    user.has_password? || user.authentications.size > 1
  end

  def expire_token!
    self.update_column(:token_expired, true)
  end

  def token_expired?
    (self.token_expires && self.token_expires_at && self.token_expires_at.utc < Time.zone.now.utc) || self.token_expired
  end

  def update_info
    UpdateInfoJob.perform(self) unless self.information_fetched
  end

  private

  def find_friends
    FindFriendsJob.perform(self)
  end

end
