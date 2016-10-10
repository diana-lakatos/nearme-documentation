class Support::TicketMessage < ActiveRecord::Base
  self.table_name = 'support_ticket_messages'

  has_paper_trail
  auto_set_platform_context
  scoped_to_platform_context

  # attr_accessible :full_name, :email, :subject, :message

  belongs_to :user, -> { with_deleted }
  belongs_to :ticket, class_name: 'Support::Ticket', touch: true
  belongs_to :instance

  has_many :attachments, -> { order 'created_at DESC' }, class_name: 'Support::TicketMessageAttachment', dependent: :destroy

  validates :full_name, presence: true
  validates :email, presence: true
  validates :subject, presence: true
  validates :message, presence: true
  validate :ticket_is_open

  before_validation :populate_data

  after_create :assign_ticket

  accepts_nested_attributes_for :attachments, allow_destroy: true

  def populate_data
    origin = ticket
    if origin && origin.first_message
      attrs = origin.first_message.attributes.slice('full_name', 'email', 'subject')
      assign_attributes(attrs)
    end
  end

  def ticket_is_open
    errors.add(:state, 'Bad state') unless ticket.open? if ticket
  end

  def can_reply?(email, ticket_id)
    ticket = Support::Ticket.find(ticket_id)
    ticket.can_reply?(email)
  end

  def receive(message, params)
    from = message.from[0]
    ticket_id = params['ticket_id']

    if can_reply?(from, ticket_id)
      self.email = from
      self.ticket_id = ticket_id
      self.message = Support::Ticket.body_for_message(message)
      self.instance_id = ticket.first_message.instance_id

      if user_message?
        populate_data
        self.user_id = ticket.first_message.user_id
      else
        u = User.find_by_email(from)
        self.subject = ticket.first_message.subject
        self.full_name = u.name
        self.user_id = u.id
      end
      self.save!
    end
  end

  def user_message?
    email == ticket.first_message.email if ticket.messages.count > 0
  end

  def assign_ticket
    ticket.assign_to!(user) if !ticket.assigned? && !user_message?
  end

  def full_name
    user ? user.name : self[:full_name]
  end

  def to_liquid
    @support_ticket_message_drop ||= Support::TicketMessageDrop.new(self)
  end
end
