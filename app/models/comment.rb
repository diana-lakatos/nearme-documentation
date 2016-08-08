class Comment < ActiveRecord::Base

  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  include CreationFilter

  belongs_to :commentable, polymorphic: true, touch: true
  belongs_to :creator, -> { with_deleted }, class_name: "User", inverse_of: :comments

  has_many :spam_reports, as: :spamable, dependent: :destroy

  validates :body, presence: true, length: { maximum: 5000 }

  validate :group_membership, if: :group_activity_commented?

  after_commit :user_commented_event, on: :create
  def user_commented_event
    case self.commentable_type
    when "ActivityFeedEvent"
      event = :user_commented

      if self.commentable.event_source.try(:updateable_type).eql?('Group')
        event = :user_commented_on_user_activity
      end

      followed = self.commentable.followed
    when "Project"
      event = :user_commented_on_project
      followed = self.commentable.creator
    else
      return
    end

    affected_objects = [self.creator]
    ActivityFeedService.create_event(event, followed, affected_objects, self)
  end

  def reported_by(user, ip)
    if user
      self.spam_reports.where(user: user).first
    else
      self.spam_reports.where(ip_address: ip, user: nil).first
    end
  end

  def can_be_reported?
    !spam_ignored
  end

  def can_remove?(current_user, passed_commentable = commentable)
    return unless current_user
    [creator, passed_commentable.creator].include?(current_user)
  end

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
