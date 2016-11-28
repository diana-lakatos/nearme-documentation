# frozen_string_literal: true
class AvailabilityTemplateForm < BaseForm
  property :id
  property :_destroy, virtual: true

  include Reform::Form::ActiveModel::ModelReflections
  class << self
    def decorate(configuration)
      Class.new(self) do
        configuration.each do |field, options|
          validates :"#{field}", options[:validation] if options[:validation].present?
        end
      end
    end
  end
  # property :unavailable_period_enabled

  collection :availability_rules, form: AvailabilityRuleForm,
    populate_if_empty: -> (fragment:, **) { model.availability_rules.build }

  collection :schedule_exception_rules, form: ScheduleExceptionRuleForm,
    populator: -> (collection:, fragment:, index:, **) {
    item = schedule_exception_rules.find { |ser| ser.id.to_s == fragment["id"].to_s && fragment["id"].present? }
    if fragment["_destroy"] == "1"
      schedule_exception_rules.delete(item)
      return skip!
    end
    item ? item : schedule_exception_rules.append(model.schedule_exception_rules.build)
  }

  def build_schedule_exception_rules
    ScheduleExceptionRuleForm.new(model.schedule_exception_rules.build)
  end

  def build_availability_rules
    AvailabilityRuleForm.new(model.availability_rules.build)
  end
end
