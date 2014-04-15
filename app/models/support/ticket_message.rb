class Support::TicketMessage < ActiveRecord::Base
  self.table_name = 'support_ticket_messages'

  has_paper_trail
  auto_set_platform_context
  scoped_to_platform_context

  attr_accessible :full_name, :email, :subject, :message

  belongs_to :user
  belongs_to :ticket, class_name: 'Support::Ticket', touch: true
  belongs_to :instance

  validates :full_name, presence: true
  validates :email, presence: true
  validates :subject, presence: true
  validates :message, presence: true
  validate :ticket_is_open

  before_validation :populate_data

  after_create :assign_ticket

  def populate_data
    origin = self.ticket
    if origin && origin.first_message
      attrs = origin.first_message.attributes.slice("full_name", "email", "subject")
      self.assign_attributes(attrs)
    end
  end

  def ticket_is_open
    if self.ticket
      errors.add(:state, 'Bad state') unless self.ticket.open?
    end
  end

  def can_reply?(email, ticket_id)
    ticket = Support::Ticket.find(ticket_id)
    ticket.can_reply?(email)
  end

  def receive(message, params)
    from = message.from[0]
    ticket_id = params['ticket_id']
    encoding = Array.wrap(message.content_type.split('charset=')).last
    body = message.body.to_s.force_encoding(encoding).encode('UTF-8')

    if can_reply?(from, ticket_id)
      self.email = from
      self.ticket_id = ticket_id
      self.message = body
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
    if ticket.messages.count > 0
      self.email == ticket.first_message.email
    end
  end

  def assign_ticket
    if not ticket.assigned? and not user_message?
      self.ticket.assign_to!(self.user)
    end
  end

  def to_liquid
    Support::TicketMessageDrop.new(self)
  end
end
