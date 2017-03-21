# frozen_string_literal: true
class Authentication < ActiveRecord::Base
  class InvalidToken < StandardError; end
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :user, touch: true
  belongs_to :instance

  has_many :user_relationships
  has_many :connections, through: :user_relationships, source: :follower, class_name: 'User'

  validates :provider, :uid, :token, presence: true
  validates :provider, uniqueness: { scope: [:instance_id, :user_id] }
  validates :uid,      uniqueness: { scope: [:instance_id, :provider, :deleted_at] }

  serialize :info, Hash

  delegate :new_connections, :friend_ids, to: :social_connection, allow_nil: true

  scope :with_valid_token, lambda {
    where('authentications.token_expires_at > ? OR authentications.token_expires_at IS NULL', Time.now)
      .where(token_expired: false)
  }

  after_commit :find_friends, on: :create
  after_commit :update_info, on: :create

  PROVIDERS = %w(Facebook LinkedIn Twitter Instagram Google GitHub).freeze
  ALLOWED_LOGIN_PROVIDERS = PROVIDERS + ['SAML'] - ['Instagram']

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

  delegate :count, to: :connections, prefix: true

  def can_be_deleted?
    # we can delete authentication if user has other option to log in, i.e. has set password or other authentications
    user.encrypted_password.present? || user.authentications.size > 1
  end

  def expire_token!
    update_column(:token_expired, true)
  end

  def token_expired?
    (token_expires && token_expires_at && token_expires_at.utc < Time.zone.now.utc) || token_expired
  end

  def update_info
    UpdateInfoJob.perform(id) unless information_fetched
  end

  private

  def find_friends
    FindFriendsJob.perform(id)
  end
end
