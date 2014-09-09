class Support::Ticket < ActiveRecord::Base
  self.table_name = 'support_tickets'

  has_paper_trail
  has_metadata :without_db_column => true
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :user
  belongs_to :assigned_to, class_name: 'User'
  belongs_to :instance
  has_many :messages, -> { order 'created_at DESC' }, class_name: 'Support::TicketMessage', dependent: :destroy
  scope :metadata, -> {select('state, COUNT(*) as count').group(:state)}
  scope :user_metadata, -> {select('instance_id, COUNT(*) as count').group(:instance_id)}

  state_machine :state, initial: :open do
    event :resolve do
      transition :open => :resolved
    end
  end

  scope :for_filter, ->(filter) { filter == 'all' ? scoped : where('state = ?', filter)}

  accepts_nested_attributes_for :messages

  def verb
    (self.state + 'ed').humanize
  end

  def open_text
    I18n.t(self.state, scope: [:support, :ticket, :open_text])
  end

  def assigned?
    self.assigned_to.presence
  end

  def receive(message, params)
    from = message.from[0]
    to = message.to[0]

    if message.multipart?
      part = message.parts[0]
    else
      part = message
    end

    encoding = Array.wrap(part.content_type.split('charset=')).last || 'UTF-8'
    body = part.body.to_s.force_encoding(encoding).encode('UTF-8')

    self.instance = PlatformContext.current.instance

    if self.instance
      ticket_message = self.messages.new
      ticket_message.email = from
      ticket_message.full_name = message[:from].display_names.first || 'Unknown'
      ticket_message.subject = message.subject
      ticket_message.message = body
      ticket_message.instance_id = self.instance_id
      self.save!
    end
    SupportMailer.enqueue.request_received(self, self.first_message)
    SupportMailer.enqueue.support_received(self, self.first_message)
  end

  def admin_emails
    instance.instance_admins.includes(:user).collect(&:user).collect(&:email)
  end

  def can_reply?(email)
    valid_emails = [
      first_message.try(:email),
      admin_emails
    ].flatten.compact
    valid_emails.include?(email)
  end

  def assign_to!(user)
    self.assigned_to = user
    self.save!
  end

  def subject
    first_message.try(:subject)
  end

  def first_message
    messages.last
  end

  def recent_message
    messages.first
  end

  def assign_user(user)
    first_message.full_name = user.name
    first_message.email = user.email
    first_message.user = user
    self.user = user
  end

  def to_liquid
    Support::TicketDrop.new(self)
  end
end
