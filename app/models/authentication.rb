class Authentication < ActiveRecord::Base
  attr_accessible :user_id, :provider, :uid, :info, :token, :secret, :token_expires_at
  belongs_to :user

  validates :provider, :uid, :token, presence: true
  validates :provider, uniqueness: { scope: :user_id }
  validates :uid,      uniqueness: { scope: :provider }

  serialize :info, Hash

  delegate :new_connections, to: :social_connection

  scope :with_valid_token,   -> {where(arel_table[:token_expires_at].gt(Time.now).or(arel_table[:token_expires_at].eq(nil)))}
  scope :with_invalid_token, -> {where(arel_table[:token_expires_at].ltqe(Time.now))}

  AVAILABLE_PROVIDERS = ["Facebook", "LinkedIn", "Twitter" ]

  def social_connection
    @social_connection ||= "Authentication::#{provider_name.capitalize}Provider".constantize.new(self)
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
