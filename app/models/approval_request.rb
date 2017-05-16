class ApprovalRequest < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  DATE_VALUES = %w(today yesterday week_ago month_ago 3_months_ago 6_months_ago)

  belongs_to :instance
  belongs_to :uploader, -> { with_deleted }, class_name: 'User'
  belongs_to :owner, -> { with_deleted }, polymorphic: true
  belongs_to :approval_request_template, -> { with_deleted }

  scope :pending, -> { with_state(:pending) }
  scope :approved, -> { with_state(:approved) }
  scope :rejected, -> { with_state(:rejected) }
  scope :questioned, -> { with_state(:questionable) }
  scope :for_non_drafts, -> { where(draft_at: nil) }

  scope :with_date, ->(date) { where(created_at: date) }

  scope :by_search_query, lambda  { |q|
    joins("LEFT join locations on locations.id = owner_id AND owner_type = 'Location'")
      .joins("LEFT join users on users.id = owner_id AND owner_type = 'User'")
      .joins("LEFT join transactables on transactables.id = owner_id AND owner_type = 'Transactable'")
      .joins("LEFT join companies on companies.id = owner_id AND owner_type = 'Company'")
      .where('locations.name ilike ? or users.name ilike ? or transactables.name ilike ? or companies.name ilike ?', q, q, q, q)
  }

  before_create :set_defaults
  before_save :set_draft

  has_many :approval_request_attachments, inverse_of: :approval_request
  accepts_nested_attributes_for :approval_request_attachments, reject_if: ->(params) { params[:file].nil? && params[:file_cache].nil? }

  validates :message, presence: true, if: ->(ar) { ar.required_written_verification }
  validates :message, length: { maximum: 255 }
  validate :validate_presence_of_attachments

  def set_defaults
    self.state = 'pending'
  end

  def set_draft
    self.draft_at = owner.try(:draft) || owner.try(:draft_at)
  end

  state_machine :state, initial: :pending do
    after_transition approved: :pending, do: :notify_owner_of_cancelling_acceptance
    after_transition pending: :approved, do: :notify_owner_of_acceptance
    after_transition pending: :rejected, do: :notify_owner_of_rejection
    after_transition pending: :questionable, do: :notify_owner_of_question

    event :review do
      transition [:approved, :rejected, :questionable] => :pending
    end

    event :accept do
      transition pending: :approved
    end

    event :reject do
      transition pending: :rejected
    end

    event :question do
      transition pending: :questionable
    end
  end

  def to_liquid
    @approval_request_drop ||= ApprovalRequestDrop.new(self)
  end

  def message_blank_or_changed?
    message.blank? || (message_was != message)
  end

  def notify_owner_of_cancelling_acceptance
    owner.approval_request_acceptance_cancelled! if owner.respond_to?(:approval_request_acceptance_cancelled!)
  end

  def notify_owner_of_acceptance
    owner.approval_request_approved! if owner.respond_to?(:approval_request_approved!)
  end

  def notify_owner_of_rejection
    owner.approval_request_rejected!(id) if owner.respond_to?(:approval_request_rejected!)
  end

  def notify_owner_of_question
    owner.approval_request_questioned!(id) if owner.respond_to?(:approval_request_questioned!)
  end

  private

  def validate_presence_of_attachments
    if approval_request_template.present?
      approval_request_template.approval_request_attachment_templates.each do |arat|
        if arat.required?
          ara = approval_request_attachments.find { |ara| ara.approval_request_attachment_template_id == arat.id }
          if ara.blank?
            errors.add(:attachments, I18n.t('approval_request_attachments.attachments_are_missing'))
          end
        end
      end
    end
  end
end
