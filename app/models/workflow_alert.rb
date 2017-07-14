# frozen_string_literal: true
class WorkflowAlert < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  # Required for deploy because of the order of migrations (older migrations work on not yet created bcc field)
  # not used otherwise in other places
  attr_accessor :skip_bcc_validation

  ALERT_TYPES = %w(email sms api_call).freeze
  RECIPIENT_TYPES = %w(lister enquirer).freeze
  REQUEST_TYPE = %w(GET POST PUT DELETE).freeze
  BCC_TYPES = %w(collaborators members).freeze

  scope :enabled, -> { where(enabled: true) }
  scope :for_sms_path, ->(path) { where(alert_type: 'sms', template_path: path) }
  scope :for_api_calls_path, ->(path) { where(alert_type: 'api_call', template_path: path) }
  scope :for_email_path, ->(path) { where(alert_type: 'email', template_path: path) }
  scope :for_email_layout_path, ->(path) { where(alert_type: 'email', layout_path: path) }
  scope :by_search_query, lambda { |query|
    where('workflow_alerts.name ilike :query or workflow_alerts.template_path ilike :query or '\
          'workflow_alerts.subject ilike :query',
          query: query)
  }
  scope :by_from_field, lambda { |query|
    where('workflow_alerts.from ilike :query', query: query)
  }
  scope :by_reply_to_field, lambda { |query|
    where('workflow_alerts.from ilike :query', query: query)
  }

  has_many :form_configuration_workflow_alerts, dependent: :destroy
  has_many :form_configurations, through: :form_configuration_workflow_alerts

  belongs_to :workflow_step
  belongs_to :instance

  validates :name, presence: true
  validates :alert_type, inclusion: { in: ALERT_TYPES, allow_nil: false }
  validates :recipient_type, inclusion: { in: ->(wa) { wa.recipient_types }, allow_blank: true }
  validates :from_type, inclusion: { in: ->(wa) { wa.recipient_types }, allow_blank: true }
  validates :reply_to_type, inclusion: { in: ->(wa) { wa.recipient_types }, allow_blank: true }
  validates :request_type, inclusion: { in: REQUEST_TYPE, allow_nil: true }
  validates :bcc_type, inclusion: { in: :bcc_types, allow_blank: true, unless: ->(wa) { wa.skip_bcc_validation } }
  validates :template_path, uniqueness: { scope: [:workflow_step_id, :recipient_type, :alert_type, :deleted_at] }
  validates :template_path, presence: { unless: ->(wa) { wa.alert_type == 'api_call' } }
  validates :from, email: true, allow_blank: true
  validates :cc, emails_list: true, allow_blank: true
  validates :bcc, emails_list: true, allow_blank: true, unless: ->(wa) { wa.skip_bcc_validation }
  validate :payload_data_is_parsable, if: ->(wa) { wa.alert_type == 'api_call' }
  validate :headers_is_parsable, if: ->(wa) { wa.alert_type == 'api_call' }
  validates :endpoint, presence: { if: ->(wa) { wa.alert_type == 'api_call' } }

  serialize :custom_options, Hash

  def recipient_types
    RECIPIENT_TYPES + InstanceAdminRole.pluck(:name)
  end

  def bcc_types
    BCC_TYPES + InstanceAdminRole.pluck(:name)
  end

  def makes_sense_to_associate_with_transactable_type?
    workflow_step.associated_class.constantize.belongs_to_transactable_type?
  end

  def should_be_triggered?(step, metadata: {})
    condition = prevent_trigger_condition.to_s.strip
    return true if condition.blank?
    begin
      result = Liquid::Template.parse(
        "{% if #{prevent_trigger_condition} %} Do not run {% endif %}"
      ).render(step.data.merge(
        'metadata' => metadata,
        'platform_context' => PlatformContext.current.decorate
      )
      .stringify_keys, filters: [Liquid::LiquidFilters])
    rescue => e
      result = ''
      MarketplaceLogger.error('Workflow Alert Prevent Trigger Liquid Error',
                              "Error parsing condition for workflow alert: #{id} - #{e}", raise: false)
    end
    result.to_s.strip.blank?
  end

  protected

  def payload_data_is_parsable
    JSON.parse(Liquid::Template.parse(payload_data).render)
  rescue JSON::ParserError
    errors.add(:payload_data, 'not valid json')
  end

  def headers_is_parsable
    JSON.parse(headers)
  rescue JSON::ParserError
    errors.add(:headers, 'not valid json')
  end
end
