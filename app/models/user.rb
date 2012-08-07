class User < ActiveRecord::Base

  include Gravtastic

  is_gravtastic!

  has_many :authentications
  has_many :bookings
  has_many :reservations, :foreign_key => :owner_id
  has_many :workplaces, :foreign_key => "creator_id"
  has_many :workplace_bookings, :through => :workplaces, :source => :bookings

  mount_uploader :avatar, AvatarUploader

  validates_presence_of :name

  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :trackable, :validatable, :token_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :phone

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

  def apply_omniauth(omniauth)
    self.name = omniauth['info']['name'] if email.blank?
    self.email = omniauth['info']['email'] if email.blank?
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
  end

  def password_required?
    false
  end

  # No password auth
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
end
