class User < ActiveRecord::Base
  include Gravtastic

  before_save :ensure_authentication_token
  # Includes billing gateway helper method and sets up billing charge association
  include BillingGateway::UserHelper

  is_gravtastic!

  acts_as_paranoid

  has_many :authentications,
           :dependent => :destroy

  has_many :companies,
           :foreign_key => "creator_id"
  attr_accessible :companies_attributes
  accepts_nested_attributes_for :companies

  has_many :locations,
           :through => :companies,
           :dependent => :destroy

  has_many :reservations,
           :foreign_key => :owner_id

  has_many :listings,
           :through => :locations

  has_many :photos,
           :through => :listings

  has_many :listing_reservations,
           :through => :listings,
           :source => :reservations

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

  has_many :user_industries
  has_many :industries, :through => :user_industries


  mount_uploader :avatar, AvatarUploader


  validates_presence_of :name
  validates_presence_of :password, :if => :password_required?
  validates_presence_of :email
  validates :avatar, :file_mime_type => {:content_type => /image/}, :if => Proc.new{|user| user.avatar.file.present? && user.avatar.file.content_type.present?}

  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :trackable, :validatable, :token_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :phone, :job_title, :password, :password_confirmation, :avatar, :biography, :industry_ids

  delegate :to_s, :to => :name

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
    use_social_provider_image(omniauth['info']['image']) if omniauth['info']['image']
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
  end


  def cancelled_reservations
    reservations.cancelled
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

  def first_name
    name.split(' ', 2)[0]
  end

  def last_name
    name.split(' ', 2)[1]
  end

  def avatar_changed?
    false
  end

  def default_company
    self.companies.first
  end

  def use_social_provider_image(url)
    self.remote_avatar_url = url unless avatar_provided?
  end

  def avatar_provided?
    return AvatarUploader.new.to_s != self.avatar.to_s
  end
end
