class Comment < ActiveRecord::Base

  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  include CreationFilter

  belongs_to :commentable, polymorphic: true
  belongs_to :creator, -> { with_deleted }, class_name: "User", inverse_of: :comments

  has_many :spam_reports, as: :spamable, dependent: :destroy

  validates :body, presence: true, length: { maximum: 5000 }

  after_commit :user_commented_event, on: :create
  def user_commented_event
    case self.commentable_type
    when "ActivityFeedEvent"
      event = :user_commented
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

  def can_remove?(current_user)
    return unless current_user
    [creator, commentable.creator].include?(current_user)
  end

  def event
    body
  end
end
