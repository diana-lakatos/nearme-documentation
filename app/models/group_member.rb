class GroupMember < ActiveRecord::Base
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :user
  belongs_to :group

  validates :user, presence: { message: I18n.t(:not_exist)}
  validates_uniqueness_of :user, scope: :group_id

  validates :group, presence: true

  scope :moderator, -> { where(moderator: true) }
  scope :member, -> { where(moderator: false) }

  scope :approved, -> { where.not(approved_by_owner_at: nil, approved_by_user_at: nil) }
  scope :for_user, -> (user) { user.present? ? where('user_id = ? OR email = ?', user.id, user.email) : [] }

  scope :by_phrase, -> (phrase) { joins(:user).where('users.name ilike ?', "%#{phrase}%") }

  def name
    @name ||= user.try(:name)
  end

  def pending?
    !approved?
  end

  def approved?
    approved_by_owner_at.present? && approved_by_user_at.present?
  end

  def approved_by_owner?
    approved_by_owner_at.present?
  end

  def approved_by_user?
    approved_by_user_at.present?
  end

  def waiting_for_user_response?
    approved_by_owner? && !approved_by_user?
  end

  def waiting_for_owner_response?
    approved_by_user? && !approved_by_owner?
  end

end
