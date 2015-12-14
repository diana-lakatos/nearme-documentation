class ProjectCollaborator < ActiveRecord::Base
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :user

  counter_culture :user,
    column_name: ->(p) { p.approved? ? 'project_collborations_count' : nil },
    column_names: { ["project_collaborators.approved_by_owner_at IS NOT NULL AND project_collaborators.approved_by_user_at IS NOT NULL AND project_collaborators.deleted_at IS NULL"] => 'project_collborations_count' }

  belongs_to :project

  validates :user, presence: { message: I18n.t(:not_exist)}
  validates_uniqueness_of :user, scope: :project_id

  validates :project, presence: true

  scope :approved, -> { where.not(approved_by_owner_at: nil, approved_by_user_at: nil) }
  scope :for_user, -> (user) { user.present? ? where('user_id = ? OR email = ?', user.id, user.email) : [] }

  def name
    @name ||= user.try(:name)
  end

  def pending?
    !approved?
  end

  def approved?
    approved_by_owner_at.present? && approved_by_user_at.present?
  end

  def approved=(approve=nil)
    self.update_attribute(:approved_by_owner_at, Time.zone.now) if approve.present?
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
