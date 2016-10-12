class RecurringBooking::NextDateFactory
  def self.get_calculator(pricing, previous_date)
    case pricing.unit
    when 'subscription_month'
      NextChargeDateMonthlyCalculator
    when 'subscription_day'
      NextChargeDateDailyCalculator
    else
      fail NotImplementedError
    end.new(pricing, previous_date)
  end

  class NextChargeDateBaseCalculator
    def initialize(pricing, date)
      @pricing = pricing
      @date = date
    end

    def next_charge_date
      fail NotImplementedError
    end
  end

  class NextChargeDateDailyCalculator < NextChargeDateBaseCalculator
    def next_charge_date
      @date + @pricing.number_of_units.days
    end
  end

  class NextChargeDateMonthlyCalculator < NextChargeDateBaseCalculator
    def next_charge_date
      @date.beginning_of_month.next_month
    end
  end
end
