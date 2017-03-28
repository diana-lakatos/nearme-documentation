# frozen_string_literal: true
# user-to-user message
class UserMessage < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  scoped_to_platform_context

  attr_accessor :replying_to_id

  belongs_to :author, -> { with_deleted }, class_name: 'User'           # person that wrote this message
  belongs_to :instance
  belongs_to :thread_owner, -> { with_deleted }, class_name: 'User'     # user that started conversation
  belongs_to :thread_recipient, -> { with_deleted }, class_name: 'User' # user that is conversation recipient
  belongs_to :thread_context, -> { with_deleted }, polymorphic: true    # conversation context: Transactable, Reservation, User
  has_many :attachments, class_name: 'Attachable::Attachment', as: :attachable

  validates :author_id, presence: true
  validates :thread_owner_id, presence: true
  validates :thread_recipient_id, presence: true
  validates :body, presence: { message: "Message can't be blank." }, if: ->(um) { um.attachments.empty? }
  validates :body, length: { maximum: 2000, message: 'Message cannot have more than 2000 characters.' }
  validates :attachments, presence: true, unless: ->(um) { um.body.present? }

  scope :for_user, lambda { |user|
    where('"user_messages"."thread_owner_id" = :id OR "user_messages"."author_id" = :id OR "user_messages"."thread_recipient_id" = :id', id: user.id).order('user_messages.created_at asc')
  }
  scope :by_created, -> { order('created_at desc') }
  scope :for_transactable, ->(transactable) do
    where('("user_messages"."thread_context_type" = ? AND "user_messages"."thread_context_id" IN (?)) OR
          ("user_messages"."thread_context_type" = ? AND "user_messages"."thread_context_id" = ?)',
          'TransactableCollaborator', transactable.transactable_collaborators.pluck(:id), 'Transactable', transactable.id)
  end

  after_create :update_recipient_unread_message_counter, :mark_as_read_for_author

  accepts_nested_attributes_for :attachments, allow_destroy: true

  def thread_scope
    [[thread_owner_id, thread_recipient_id, author_id].uniq.sort.join('-'), thread_context_id, thread_context_type]
  end

  def previous_in_thread
    UserMessage.find(replying_to_id)
  end

  def first_in_thread?
    replying_to_id.blank?
  end

  def read_column_for(user)
    "read_for_#{kind_for(user)}"
  end

  def read_for?(user)
    send read_column_for(user)
  end

  def unread_for?(user)
    !read_for?(user)
  end

  def mark_as_read_for!(user)
    column = read_column_for(user)
    send("#{column}=", true)
    save!
  end

  def archived_column_for(user)
    "archived_for_#{kind_for(user)}"
  end

  def archived_for?(user)
    send archived_column_for(user)
  end

  def archive_for!(user)
    column = archived_column_for(user)
    update_column(column, true)
  end

  def to_liquid
    @user_message_drop ||= UserMessageDrop.new(self)
  end

  def send_notification
    return if thread_context_type.blank?
    WorkflowStepJob.perform(WorkflowStep::UserMessageWorkflow::Created, id)
    return if thread_context_type != 'Transactable'

    if author == thread_context.administrator
      WorkflowStepJob.perform(WorkflowStep::UserMessageWorkflow::TransactableMessageFromLister, id)
    else
      WorkflowStepJob.perform(WorkflowStep::UserMessageWorkflow::TransactableMessageFromEnquirer, id)
    end
  end

  def recipient
    author_with_deleted == thread_owner_with_deleted ? thread_recipient_with_deleted : thread_owner_with_deleted
  end

  def thread_context_with_deleted
    return nil if thread_context_type.nil?
    @thread_context_with_deleted ||= thread_context_type.constantize.with_deleted.find_by(id: thread_context_id)
  end

  def author_with_deleted
    author.presence || User.with_deleted.find_by(id: author_id)
  end

  def thread_owner_with_deleted
    thread_owner.presence || User.with_deleted.find(thread_owner_id)
  end

  def thread_recipient_with_deleted
    thread_recipient.presence || User.with_deleted.find(thread_recipient_id)
  end

  def set_message_context_from_request_params(params, current_user)
    UserMessageThreadConfigurator.new(self, params, current_user).run
  end

  # check if author of this message can join conversation in message_context
  def author_has_access_to_message_context?
    case thread_context
    when Transactable, User, TransactableCollaborator
      true
    when Reservation, RecurringBooking, DelayedReservation, Offer, Purchase, Order
      author == thread_context.owner ||
        author == thread_context.transactable.administrator ||
        author == thread_context.transactable.creator ||
        author.can_manage_listing?(thread_context.transactable)
    else
      false
    end
  end

  def update_unread_message_counter_for(user)
    actual_count = unread_user_message_threads_count_for(user.reload)

    user.instance_unread_messages_threads_count ||= {}
    user.instance_unread_messages_threads_count[instance_id] = actual_count
    user.save(validate: false)
  end

  def the_other_user(current_user)
    author_id == current_user.id ? thread_recipient : author
  end

  private

  def kind_for(user)
    user.id == author_id ? :owner : :recipient
  end

  def update_recipient_unread_message_counter
    update_unread_message_counter_for(recipient)
  end

  def mark_as_read_for_author
    mark_as_read_for!(author) if author != recipient
  end

  def unread_user_message_threads_count_for(user)
    user_messages_decorator_for(user).inbox.unread.fetch.size
  end

  def user_messages_decorator_for(user)
    @user_messages_decorator ||= UserMessagesDecorator.new(user.user_messages, user)
  end
end
