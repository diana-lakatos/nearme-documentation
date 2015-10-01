class Comment < ActiveRecord::Base

  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :commentable, polymorphic: true
  belongs_to :creator, -> { with_deleted }, class_name: "User", inverse_of: :comments

  has_many :spam_reports, as: :spamable, dependent: :destroy

  validates :body, presence: true

  after_commit :user_commented_event, on: :create
  def user_commented_event
    if self.commentable_type == "ActivityFeedEvent"
      event = :user_commented
      ActivityFeedService.create_event(event, self.commentable.followed, [self.creator], self)
    end
  end

  def reported_by(user, ip)
    if user
      self.spam_reports.where(user: user).first
    else
      self.spam_reports.where(ip_address: ip, user: nil).first
    end
  end

  def can_remove?(current_user)
    return unless current_user
    [creator, commentable.creator].include?(current_user)
  end

  def event
    body
  end
end
