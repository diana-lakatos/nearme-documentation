# frozen_string_literal: true
class AvailabilityTemplateForm < BaseForm
  model :availability_template

  class << self
    def decorate(configuration)
      Class.new(self) do
        configuration.each do |field, options|
          add_validation(field, options)
        end
      end
    end
  end

  # @!attribute id
  #   @return [Integer] numeric identifier for the availability
  #     template
  property :id

  property :_destroy, virtual: true

  # @!attribute name
  #   @return [String] name of the availability template
  property :name, default: 'Custom transactable availability'

  # @!attribute availability_rules
  #   @return [Array<AvailabilityRuleForm>] array of availability rules
  collection :availability_rules, form: AvailabilityRuleForm,
                                  populator: ->(collection:, fragment:, index:, **) {
                                               item = availability_rules.find { |ar| ar.id.to_s == fragment['id'].to_s && fragment['id'].present? }
                                               if fragment['_destroy'] == '1'
                                                 availability_rules.delete(item)
                                                 return skip!
                                               end
                                               return item if item
                                               availability_rules.append(model.availability_rules.build)
                                             }

  # @!attribute schedule_exception_rules
  #   @return [Array<ScheduleExceptionRuleForm>] array of schedule exception rules
  collection :schedule_exception_rules, form: ScheduleExceptionRuleForm,
                                        populator: ->(collection:, fragment:, index:, **) {
                                                     item = schedule_exception_rules.find { |ser| ser.id.to_s == fragment['id'].to_s && fragment['id'].present? }
                                                     if fragment['_destroy'] == '1'
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
