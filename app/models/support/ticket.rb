class Support::Ticket < ActiveRecord::Base
  self.table_name = 'support_tickets'

  has_paper_trail
  has_metadata without_db_column: true
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :assigned_to, -> { with_deleted }, class_name: 'User'
  belongs_to :instance
  belongs_to :target, -> { with_deleted }, polymorphic: true
  belongs_to :user, -> { with_deleted }

  has_many :messages, -> { order 'created_at DESC' }, class_name: 'Support::TicketMessage', dependent: :destroy
  has_many :attachments, class_name: 'Support::TicketMessageAttachment'

  scope :metadata, -> { select('support_tickets.state, COUNT(*) as count').group(:state) }
  scope :user_metadata, -> { select('support_tickets.instance_id, COUNT(*) as count').group(:instance_id) }

  serialize :reservation_details, Hash

  state_machine :state, initial: :open do
    event :resolve do
      transition open: :resolved
    end
  end

  scope :for_filter, ->(filter) { filter == 'all' ? all : where('support_tickets.state = ?', filter) }

  accepts_nested_attributes_for :messages

  def self.body_for_message(message)
    part = message.multipart? ? message.parts[0] : message

    match_data = part.content_type.try(:match, /charset=(?<encoding>[\w\d-]+)/)
    match_data ? part.body.to_s.force_encoding(match_data[:encoding]).encode('UTF-8') : part.body.to_s
  end

  def verb
    I18n.t("support.statuses.past.#{state}")
  end

  def open_text
    I18n.t(state, scope: [:support, :ticket, :open_text])
  end

  def assigned?
    assigned_to.presence
  end

  def receive(message, _params)
    from = message.from[0]

    self.instance = PlatformContext.current.instance
    self.target = PlatformContext.current.instance

    if instance
      ticket_message = messages.new
      ticket_message.email = from
      ticket_message.full_name = message[:from].display_names.first || 'Unknown'
      ticket_message.subject = message.subject.presence || '<no subject>'
      ticket_message.message = self.class.body_for_message(message).to_s.strip.presence || '(No message text)'
      ticket_message.instance_id = instance_id
      self.save!
      WorkflowStepJob.perform(WorkflowStep::SupportWorkflow::Created, ticket_message.id)
    end
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

  def assign_to(user)
    self.assigned_to = user
  end

  def assign_to!(user)
    assign_to(user)
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
    @support_ticket_drop ||= Support::TicketDrop.new(self)
  end

  def reservation_dates
    if @reservation_dates.nil?
      @reservation_dates = reservation_details['dates'].try(:split, ',') || []
      @reservation_dates.map!(&:to_date)
    end
    @reservation_dates
  end

  def reservation_date
    if @reservation_date.nil?
      @reservation_date =  reservation_details['dates'].try(:to_datetime)
    end
    @reservation_date
  end

  def reservation_pricing
    if reservation_details[:transactable_pricing_id]
      @pricing ||= Transactable::Pricing.find(reservation_details[:transactable_pricing_id]).decorate
    end
  end

  def target_rfq?
    target_type == 'Transactable'
  end
end
