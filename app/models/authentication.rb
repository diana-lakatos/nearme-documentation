class Authentication < ActiveRecord::Base
  attr_accessible :user_id, :provider, :uid
  belongs_to :user

  validates :provider, :uid, presence: true
  validates :provider, uniqueness: { scope: :user_id }
  validates :uid,      uniqueness: { scope: :provider }

  serialize :info, Hash

  def provider_name
    if provider == 'open_id'
      "OpenID"
    else
      provider.titleize
    end
  end
end
