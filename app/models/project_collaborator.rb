class ProjectCollaborator < ActiveRecord::Base

  attr_accessor :email

  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :user
  belongs_to :project

  validates :user, presence: { message: I18n.t(:not_exist)}
  validates_uniqueness_of :user, scope: :project_id

  validates :project, presence: true

  scope :approved, -> { where.not(approved_by_owner_at: nil, approved_by_user_at: nil) }

  def name
    @name ||= user.try(:name)
  end

  def pending?
    !approved?
  end

  def approved?
    approved_by_owner_at && approved_by_user_at
  end

  def approved=(approve=nil)
    self.update_attribute(:approved_by_owner_at, Time.zone.now) if approve.present?
  end

  def email=(email)
    self.user = User.find_by_email(email)
  end

  def approve_by_user!
    self.update_attribute(:approved_by_user_at, Time.now)
  end

  def approved_by_user?
    approved_by_user_at.present?
  end

  def approved_by_owner?
    approved_by_owner_at.present?
  end

end
