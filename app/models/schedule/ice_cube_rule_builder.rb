require 'ice_cube'

class Schedule::IceCubeRuleBuilder

  def initialize(schedule_rule)
    @schedule_rule = schedule_rule
  end

  def to_rule
    hours = HourArrayBuilder.new(@schedule_rule).get_array
    RuleArrayBuilder.new(@schedule_rule, hours).get_rules
  end

  class HourArrayBuilder
    def initialize(schedule_rule)
      @schedule_rule = schedule_rule
    end

    def get_array
      case @schedule_rule.run_hours_mode
      when ScheduleRule::RECURRING_MODE
        if @schedule_rule.every_hours.to_f > 0
          step = @schedule_rule.every_hours * 60.minutes
          hour = @schedule_rule.time_start
          hours = []
          # add all hours after first event
          loop do
            hours << hour
            hour += step
            break if hour > @schedule_rule.time_end
          end
          hours
        else
          []
        end
      when ScheduleRule::SPECIFIC_MODE
        @schedule_rule.times
      else
        raise NotImplementedError.new("Unknown run hours mode: #{@schedule_rule.run_hours_mode}")
      end
    end
  end

  class DatesArrayBuilder

    def initialize(schedule_rule)
      @schedule_rule = schedule_rule
    end

    def get_array
      case @schedule_rule.run_dates_mode
      when ScheduleRule::SPECIFIC_MODE
        @schedule_rule.dates.map(&:in_time_zone)
      when ScheduleRule::RANGE_MODE
        arr = []
        tmp = @schedule_rule.date_start
        loop do
          arr << tmp
          break if (tmp = tmp + 1.day) > @schedule_rule.date_end
        end
        arr
      else
        raise NotImplementedError.new("Unknown run dates mode: #{@schedule_rule.run_dates_mode}")
      end
    end

  end

  class RuleArrayBuilder

    def initialize(schedule_rule, hours)
      @schedule_rule = schedule_rule
      @hours = hours
    end

    def get_rules
      case @schedule_rule.run_dates_mode
      when ScheduleRule::RECURRING_MODE
        rules = []
        @hours.group_by(&:min).each do |minute, times|
          rules << IceCube::Rule.weekly.day(@schedule_rule.week_days).hour_of_day(times.map { |t| t.in_time_zone.hour }).minute_of_hour(minute).second_of_minute(0)
        end
        rules
      when ScheduleRule::RANGE_MODE, ScheduleRule::SPECIFIC_MODE
        dates = DatesArrayBuilder.new(@schedule_rule).get_array
        RuleArrayBuilderForDates.new(@hours, dates).get_rules
      else
        raise NotImplementedError.new("Unknown run dates mode: #{@schedule_rule.run_dates_mode}")
      end
    end

    class RuleArrayBuilderForDates

      def initialize(hours, dates)
        @hours = hours
        @dates = dates
      end

      def get_rules
        rules = []
        @dates.each do |date|
          @hours.each do |time|
            t = time.in_time_zone
            d = Time.zone.parse("#{date.strftime('%Y-%m-%d')}#{t.strftime 'T%H:%M:%S%z'}").change(sec: 0)
            rules << d unless d.past?
            rules
          end
        end
        rules
      end
    end

  end

end

