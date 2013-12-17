class Authentication < ActiveRecord::Base
  class InvalidToken < Exception; end;

  attr_accessible :user_id, :provider, :uid, :info, :token, :secret,
    :token_expires_at, :token_expires, :token_expired, :profile_url

  belongs_to :user

  has_many :user_relationships
  has_many :connections, through: :user_relationships, source: :follower, class_name: 'User'

  validates :provider, :uid, :token, presence: true
  validates :provider, uniqueness: { scope: :user_id }
  validates :uid,      uniqueness: { scope: :provider }

  serialize :info, Hash

  delegate :new_connections, to: :social_connection

  scope :with_valid_token, -> {
    where('authentications.token_expires_at > ? OR authentications.token_expires_at IS NULL', Time.now).
    where(token_expired: false)
  }

  after_create :find_friends

  AVAILABLE_PROVIDERS = ["Facebook", "LinkedIn", "Twitter", "Instagram"]

  def social_connection
    @social_connection ||= "Authentication::#{provider_name.capitalize}Provider".constantize.new(self)
  end

  def provider_name
    provider.titleize
  end

  def self.available_providers
    AVAILABLE_PROVIDERS
  end

  def connections_count
    self.connections.count
  end

  def can_be_deleted?
    # we can delete authentication if user has other option to log in, i.e. has set password or other authentications
    user.has_password? || user.authentications.size > 1
  end

  def expire_token!
    self.update_attribute(:token_expired, true)
  end

  private

  def find_friends
    FindFriendsJob.perform(self)
  end
end
