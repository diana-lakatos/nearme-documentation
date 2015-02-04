class WorkflowAlert < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context


  ALERT_TYPES = %w(email sms)
  RECIPIENT_TYPES = ['lister', 'enquirer', 'administrator']

  scope :for_sms_path, -> path { where(alert_type: 'sms', template_path: path) }
  scope :for_email_path, -> path { where(alert_type: 'email', template_path: path) }
  scope :for_email_layout_path, -> path { where(alert_type: 'email', layout_path: path) }
  belongs_to :workflow_step
  belongs_to :instance

  validates_presence_of :name
  validates_inclusion_of :alert_type, in: WorkflowAlert::ALERT_TYPES, allow_nil: false
  validates_inclusion_of :recipient_type, in: WorkflowAlert::RECIPIENT_TYPES, allow_blank: true
  validates_inclusion_of :from_type, in: WorkflowAlert::RECIPIENT_TYPES, allow_blank: true
  validates_inclusion_of :reply_to_type, in: WorkflowAlert::RECIPIENT_TYPES, allow_blank: true
  validates_uniqueness_of :template_path, scope: [:workflow_step_id, :recipient_type, :alert_type, :deleted_at]
  validates_presence_of :template_path

  serialize :custom_options, Hash
end

