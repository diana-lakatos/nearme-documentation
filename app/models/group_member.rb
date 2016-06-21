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

  scope :deleted_with_group, -> (group) { where('deleted_at >= ? AND deleted_at <= ?', group.deleted_at - 30.seconds, group.deleted_at + 30.seconds) }

  scope :by_phrase, -> (phrase) { joins(:user).where('users.name ilike ?', "%#{phrase}%") }

  attr_accessor :destroyed_by_parent

  before_destroy :owner_cannot_leave_group, if: -> { !destroyed_by_parent? && member_is_an_owner? }

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

  private

  def owner_cannot_leave_group
    raise OwnerCannotLeaveGroup
  end

  def destroyed_by_parent?
    !!destroyed_by_parent
  end

  def member_is_an_owner?
    user_id.eql?(group.creator_id)
  end

  class OwnerCannotLeaveGroup < StandardError; end
end
