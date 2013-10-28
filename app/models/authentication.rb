class Authentication < ActiveRecord::Base
  attr_accessible :user_id, :provider, :uid, :info
  belongs_to :user

  validates :provider, :uid, presence: true
  validates :provider, uniqueness: { scope: :user_id }
  validates :uid,      uniqueness: { scope: :provider }

  serialize :info, Hash

  delegate :connections, to: :connection

  AVAILABLE_PROVIDERS = ["Facebook", "LinkedIn", "Twitter" ]

  def connection
    @connection ||= "Authentication::#{provider_name.capitalize}Provider".constantize.new(self)
  end

  def provider_name
    provider.titleize
  end

  def self.available_providers
    AVAILABLE_PROVIDERS
  end

  def can_be_deleted?
    # we can delete authentication if user has other option to log in, i.e. has set password or other authentications
    user.has_password? || user.authentications.size > 1
  end
end
