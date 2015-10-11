class RecurringBooking::NextDateFactory

  def self.get_calculator(interval, previous_date)
    case interval
    when 'monthly'
      NextChargeDateMonthlyCalculator
    when 'weekly'
      NextChargeDateWeeklyCalculator
    else
      raise NotImplementedError
    end.new(previous_date)
  end

  class NextChargeDateBaseCalculator

    def initialize(date)
      @date = date
    end

    def next_charge_date
      raise NotImplementedError
    end

  end

  class NextChargeDateWeeklyCalculator < NextChargeDateBaseCalculator

    def next_charge_date
      @date + 7.days
    end
  end

  class NextChargeDateMonthlyCalculator < NextChargeDateBaseCalculator

    def next_charge_date
      @date.beginning_of_month.next_month
    end

  end

end
