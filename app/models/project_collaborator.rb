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

  scope :approved, -> { where.not(approved_at: nil) }

  def name
    @name ||= user.try(:name)
  end

  def pending?
    self.approved_at.nil?
  end

  def approved?
    self.approved_at.present?
  end

  def approved=(approve=nil)
    self.update_attribute(:approved_at, Time.zone.now) if approve.present?
  end

  def email=(email)
    self.user = User.find_by_email(email)
  end

end
