class ListingMessage < ActiveRecord::Base

  attr_accessor :replying_to_id

  belongs_to :author, class_name: 'User' # person that wrote this message
  belongs_to :owner, class_name: 'User' # guest that started conversation
  belongs_to :listing

  validate :author_id, presence: true
  validate :owner_id, presence: true
  validate :body, presence: true

  def previous_in_thread
    ListingMessage.find(replying_to_id)
  end

  def first_in_thread?
    replying_to_id.blank?
  end

  def unread?
    !read?
  end

  def unread_for?(user)
    unread? && user.id != author_id
  end

  def archived_column_for(user)
    "archived_for_#{kind_for(user)}"
  end

  def archived_for?(user)
    send archived_column_for(user)
  end

  def to_liquid
    ListingMessageDrop.new(self)
  end

  def message_from_guest?
    owner == author
  end

  def send_notification(platform_context)
    if message_from_guest?
      ListingMessagingMailer.enqueue.email_message_from_guest(platform_context, self)
    else
      ListingMessagingMailer.enqueue.email_message_from_host(platform_context, self)
    end
  end

  def recipient
    message_from_guest? ? listing.administrator : owner
  end

  private

  def kind_for(user)
    if user.id == owner.id
      :owner
    else
      :listing
    end
  end

end
