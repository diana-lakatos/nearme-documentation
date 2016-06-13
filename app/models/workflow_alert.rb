class WorkflowAlert < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context


  ALERT_TYPES = %w(email sms api_call).freeze
  RECIPIENT_TYPES = ['lister', 'enquirer'].freeze
  REQUEST_TYPE = %w(GET POST PUT DELETE).freeze

  scope :for_sms_path, -> path { where(alert_type: 'sms', template_path: path) }
  scope :for_api_calls_path, -> path { where(alert_type: 'api_call', template_path: path) }
  scope :for_email_path, -> path { where(alert_type: 'email', template_path: path) }
  scope :for_email_layout_path, -> path { where(alert_type: 'email', layout_path: path) }
  belongs_to :workflow_step
  belongs_to :instance

  validates_presence_of :name
  validates_inclusion_of :alert_type, in: WorkflowAlert::ALERT_TYPES, allow_nil: false
  validates_inclusion_of :recipient_type, in: lambda { |wa| wa.recipient_types }, allow_blank: true
  validates_inclusion_of :from_type, in: lambda { |wa| wa.recipient_types }, allow_blank: true
  validates_inclusion_of :reply_to_type, in: lambda { |wa| wa.recipient_types }, allow_blank: true
  validates_inclusion_of :request_type, in: WorkflowAlert::REQUEST_TYPE, allow_nil: true
  validates_uniqueness_of :template_path, scope: [:workflow_step_id, :recipient_type, :alert_type, :deleted_at]
  validates_presence_of :template_path, unless: lambda { |wa| wa.alert_type == 'api_call' }
  validates :from, email: true, allow_blank: true
  validates :cc, emails_list: true, allow_blank: true
  validates :bcc, emails_list: true, allow_blank: true
  validate :payload_data_is_parsable, if: lambda { |wa| wa.alert_type == 'api_call' }
  validate :headers_is_parsable, if: lambda { |wa| wa.alert_type == 'api_call' }
  validates_presence_of :endpoint, if: lambda { |wa| wa.alert_type == 'api_call' }

  serialize :custom_options, Hash

  def recipient_types
    WorkflowAlert::RECIPIENT_TYPES + InstanceAdminRole.pluck(:name)
  end

  def makes_sense_to_associate_with_transactable_type?
    workflow_step.associated_class.constantize.belongs_to_transactable_type?
  end

  def should_be_triggered?(step)
    condition = self.prevent_trigger_condition.to_s.strip
    return true if condition.blank?

    begin
      result = Liquid::Template.parse("{% if #{self.prevent_trigger_condition} %} Do not run {% endif %}").render(step.data.merge('platform_context' => PlatformContext.current.decorate).stringify_keys, filters: [LiquidFilters])
    rescue => e
      result = ''
      MarketplaceLogger.error('Workflow Alert Prevent Trigger Liquid Error', "Error parsing condition for workflow alert: #{self.id} - #{e.to_s}", raise: false)
    end

    result.to_s.strip.blank?
  end

  protected

  def payload_data_is_parsable
    JSON.parse(payload_data)
  rescue JSON::ParserError
    errors.add(:payload_data, 'not valid json')
  end

  def headers_is_parsable
    JSON.parse(headers)
  rescue JSON::ParserError
    errors.add(:headers, 'not valid json')
  end

end

