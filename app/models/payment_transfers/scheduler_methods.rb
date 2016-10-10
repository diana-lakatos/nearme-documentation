module PaymentTransfers
  class SchedulerMethods
    def initialize(instance)
      @instance = instance
    end

    def next_payment_transfers_date(date = Time.zone.now.beginning_of_day)
      case @instance.payment_transfers_frequency
      when 'daily'
        date.tomorrow
      when 'semiweekly'
        date.wday >= 1 && date.wday < 4 ? date.beginning_of_week + 3.days : date.next_week
      when 'weekly'
        date.next_week
      when 'fortnightly'
        date.day >= 1 && date.day < 15 ? date.beginning_of_month + 2.weeks : date.next_month.beginning_of_month
      when 'monthly'
        date.next_month.beginning_of_month
      else
        fail NotImplementedError
      end
    end

    def generate_payment_transfers_today?
      return false if @instance.manual_transfers?

      date = Time.zone.now.beginning_of_day
      next_payment_transfers_date(date - 1.day) == date
    end
  end
end
