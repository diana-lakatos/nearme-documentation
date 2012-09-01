class User < ActiveRecord::Base

  include Gravtastic

  is_gravtastic!

  has_many :authentications
  has_many :reservations, :foreign_key => :owner_id
  has_many :listings, :foreign_key => "creator_id"
  has_many :companies, :foreign_key => "creator_id"
  has_many :locations, :foreign_key => "creator_id"
  has_many :organization_users
  has_many :organizations, :through => :organization_users

  has_many :listing_reservations, :through => :listings, :source => :reservations

  mount_uploader :avatar, AvatarUploader


  validates_presence_of :name

  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :trackable, :validatable, :token_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :organization_ids, :phone, :password, :password_confirmation

  delegate :to_s, :to => :name

  has_many :relationships,
           :class_name => "UserRelationship",
           :foreign_key => "follower_id",
           :dependent => :destroy

  has_many :followed_users,
           :through => :relationships,
           :source => :followed

  has_many :reverse_relationships,
           :class_name => "UserRelationship",
           :foreign_key => "followed_id",
           :dependent => :destroy

  has_many :followers,
           :through => :reverse_relationships,
           :source => :follower

  # Build a new user, taking into account session information such as Provider
  # authentication.
  def self.new_with_session(attrs, session)
    user = super
    user.apply_omniauth(session[:omniauth]) if session[:omniauth]
    user
  end

  def apply_omniauth(omniauth)
    self.name = omniauth['info']['name'] if name.blank?
    self.email = omniauth['info']['email'] if email.blank?
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
  end

  # Whether to validate the presence of a password
  def password_required?
    # We're changing/setting password, or new user and there are no Provider authentications
    !password.blank? || !password_confirmation.blank? ||
      (new_record? && authentications.empty?)
  end

  # Whether the user has - or should have - a password.
  def has_password?
    encrypted_password.present? || password_required?
  end

  # Don't require current_password in order to update from Devise.
  def update_with_password(attrs)
    update_attributes(attrs)
  end

  def linked_to?(provider)
    authentications.where(provider: provider).any?
  end

  def following?(other_user)
    relationships.find_by_followed_id(other_user.id)
  end

  def follow!(other_user)
    relationships.create!(followed_id: other_user.id)
  end

  def full_email
    "#{name} <#{email}>"
  end

  def may_view?(listing)
    listing.creator == self ||
      listing.required_organizations.none? ||
      listing.required_organizations.any? {|o| organizations.include? o }
  end

  def avatar_changed?
    false
  end
end
