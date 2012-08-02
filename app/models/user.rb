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
end
