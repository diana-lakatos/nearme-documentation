# frozen_string_literal: true
class FormConfiguration < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  serialize :configuration, Hash

  has_many :authorization_policies, through: :authorization_policy_associations
  has_many :authorization_policy_associations, as: :authorizable, dependent: :destroy
  has_many :form_configurations_workflows, dependent: :destroy
  has_many :workflow_steps, through: :form_configurations_workflows
  has_many :form_configuration_notifications, dependent: :destroy

  has_many :api_call_notifications, through: :form_configuration_notifications,
                                    source: :notification, source_type: 'ApiCallNotification'
  has_many :email_notifications, through: :form_configuration_notifications,
                                 source: :notification, source_type: 'EmailNotification'
  has_many :sms_notifications, through: :form_configuration_notifications,
                               source: :notification, source_type: 'SmsNotification'

  scope :with_parameterized_name, ->(name) { where(name: parameterize_name(name)).limit(1) }
  before_save :generate_parameterized_name, if: ->(object) { object.name_changed? }
  class << self
    def parameterize_name(name)
      name.to_s.downcase.tr(' ', '_')
    end
  end

  def generate_parameterized_name
    self.name = self.class.parameterize_name(name)
  end

  def build(object)
    FormBuilder.new(base_form: base_form.constantize,
                    configuration: configuration.deep_symbolize_keys,
                    object: object).build
  end

  def to_liquid
    @form_configuration_drop ||= FormConfigurationDrop.new(self)
  end
end
