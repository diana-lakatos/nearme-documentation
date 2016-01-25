class WorkflowAlert < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context


  ALERT_TYPES = %w(email sms).freeze
  RECIPIENT_TYPES = ['lister', 'enquirer'].freeze

  scope :for_sms_path, -> path { where(alert_type: 'sms', template_path: path) }
  scope :for_email_path, -> path { where(alert_type: 'email', template_path: path) }
  scope :for_email_layout_path, -> path { where(alert_type: 'email', layout_path: path) }
  belongs_to :workflow_step
  belongs_to :instance

  validates_presence_of :name
  validates_inclusion_of :alert_type, in: WorkflowAlert::ALERT_TYPES, allow_nil: false
  validates_inclusion_of :recipient_type, in: lambda { |wa| wa.recipient_types }, allow_blank: true
  validates_inclusion_of :from_type, in: lambda { |wa| wa.recipient_types }, allow_blank: true
  validates_inclusion_of :reply_to_type, in: lambda { |wa| wa.recipient_types }, allow_blank: true
  validates_uniqueness_of :template_path, scope: [:workflow_step_id, :recipient_type, :alert_type, :deleted_at]
  validates_presence_of :template_path
  validates :from, email: true, allow_blank: true
  validates :cc, emails_list: true, allow_blank: true
  validates :bcc, emails_list: true, allow_blank: true

  serialize :custom_options, Hash

  def recipient_types
    WorkflowAlert::RECIPIENT_TYPES + InstanceAdminRole.pluck(:name)
  end

  def makes_sense_to_associate_with_transactable_type?
    workflow_step.associated_class.constantize.belongs_to_transactable_type?
  end

end

