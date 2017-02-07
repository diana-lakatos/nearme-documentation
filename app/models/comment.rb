# frozen_string_literal: true
class Comment < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  include CreationFilter

  belongs_to :commentable, polymorphic: true, touch: true
  belongs_to :creator, -> { with_deleted }, class_name: 'User', inverse_of: :comments

  has_many :spam_reports, as: :spamable, dependent: :destroy

  validates :body, presence: true, length: { maximum: 5000 }

  validate :group_membership, if: :group_activity_commented?

  after_commit :user_commented_event, on: :create
  after_create :trigger_workflow_alert_for_new_comment

  def user_commented_event
    case commentable_type
    when 'ActivityFeedEvent'
      event = :user_commented

      event = :user_commented_on_user_activity if commentable.event_source.try(:updateable_type).eql?('Group')

      followed = commentable.followed
    when 'Transactable'
      event = :user_commented_on_transactable
      followed = commentable
    else
      return
    end

    affected_objects = [creator]
    ActivityFeedService.create_event(event, followed, affected_objects, self)
  end

  def trigger_workflow_alert_for_new_comment
    klass = case commentable_type
            when 'Transactable'
              WorkflowStep::CommenterWorkflow::UserCommentedOnTransactable
            when 'Group'
              WorkflowStep::CommenterWorkflow::UserCommentedOnGroup
            when 'ActivityFeedEvent'
              WorkflowStep::CommenterWorkflow::UserCommentedOnUserUpdate if commentable.event_source_type == 'UserStatusUpdate'
    end
    WorkflowStepJob.perform(klass, id) if klass.present?
    true
  end

  def reported_by(user, ip)
    if user
      spam_reports.where(user: user).first
    else
      spam_reports.where(ip_address: ip, user: nil).first
    end
  end

  def can_be_reported?
    !spam_ignored
  end

  def can_remove?(current_user, passed_commentable = commentable)
    return unless current_user
    [creator, passed_commentable.creator].include?(current_user)
  end

  alias can_edit? can_remove?

  def event
    body
  end

  private

  def group_membership
    unless creator.is_member_of?(commentable.followed)
      errors.add(:membership, I18n.t('activerecord.errors.models.comment.membership'))
    end
  end

  def group_activity_commented?
    commentable.is_a?(ActivityFeedEvent) && commentable.followed.is_a?(Group)
  end
end
