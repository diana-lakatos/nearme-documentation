# frozen_string_literal: true
class ScheduleForm < BaseForm
  property :id
  property :_destroy, virtual: true
  property :unavailable_period_enabled

  class << self
    def decorate(configuration)
      Class.new(self) do
        configuration.each do |field, options|
          add_validation(field, options)
        end
      end
    end
  end

  collection :schedule_rules, form: ScheduleRuleForm,
                              prepopulate: ->(_options) {
                                model.schedule_rules || build_default_schedule
                              },
                              populator: ->(collection:, fragment:, index:, **) {
                                           item = schedule_rules.find { |sr| sr.id.to_s == fragment['id'].to_s && fragment['id'].present? }
                                           if checked?(fragment['_destroy'])
                                             schedule_rules.delete(item)
                                             return skip!
                                           end
                                           item ? item : schedule_rules.append(model.schedule_rules.build)
                                         }

  collection :schedule_exception_rules, form: ScheduleExceptionRuleForm,
                                        populator: ->(collection:, fragment:, index:, **) {
                                                     item = schedule_exception_rules.find { |ser| ser.id.to_s == fragment['id'].to_s && fragment['id'].present? }
                                                     if checked?(fragment['_destroy'])
                                                       schedule_exception_rules.delete(item)
                                                       return skip!
                                                     end
                                                     item ? item : schedule_exception_rules.append(model.schedule_exception_rules.build)
                                                   }

  def build_schedule_exception_rules
    ScheduleExceptionRuleForm.new(model.schedule_exception_rules.build)
  end

  def build_schedule_rules
    ScheduleRuleForm.new(model.schedule_rules.build)
  end

  def build_default_schedule
    Time.use_zone('UTC') do
      model.scheduable.transactable_type_action_type.schedule.try(:schedule_rules).try(:each) do |sr|
        model.schedule_rules.build(run_hours_mode: sr.run_hours_mode, every_hours: sr.every_hours,
                                   time_start: sr.time_start, time_end: sr.time_end,
                                   times: Array.new(sr) { |t| Time.zone.local_to_utc(t).in_time_zone }, run_dates_mode: sr.run_dates_mode,
                                   week_days: sr.week_days, dates: sr.dates, date_start: sr.date_start, date_end: sr.date_end)
      end
    end
    model.schedule_rules
  end
end
