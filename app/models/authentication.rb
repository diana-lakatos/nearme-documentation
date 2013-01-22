class Authentication < ActiveRecord::Base
  attr_accessible :user_id, :provider, :uid
  belongs_to :user

  validates :provider, :uid, presence: true
  validates :provider, uniqueness: { scope: :user_id }
  validates :uid,      uniqueness: { scope: :provider }

  serialize :info, Hash

  AVAILABLE_PROVIDERS = ["Facebook", "LinkedIn", "Twitter" ]

  def provider_name
    if provider == 'open_id'
      "OpenID"
    else
      provider.titleize
    end
  end

  def self.available_providers
    AVAILABLE_PROVIDERS
  end

  def can_be_deleted?
    # we can delete authentication if user has other option to log in, i.e. has set password or other authentications
    user.has_password? || user.authentications.size > 1
  end
end
