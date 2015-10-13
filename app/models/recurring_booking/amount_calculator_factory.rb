class RecurringBooking::AmountCalculatorFactory

  def self.get_calculator(recurring_booking)
    if first_time_monthly_charge?(recurring_booking)
      FirstTimeMonthlyAmountCalculator
    else
      BaseAmountCalculator
    end.new(recurring_booking)
  end

  def self.first_time_monthly_charge?(recurring_booking)
    recurring_booking.next_charge_date.day != 1 && recurring_booking.interval == 'monthly'
  end

  class BaseAmountCalculator

    def initialize(recurring_booking)
      @recurring_booking = recurring_booking
    end

    def subtotal_amount
      @recurring_booking.subtotal_amount
    end

    def host_service_fee
      @recurring_booking.service_fee_amount_host
    end

    def guest_service_fee
      @recurring_booking.service_fee_amount_guest
    end

  end

  class FirstTimeMonthlyAmountCalculator < BaseAmountCalculator

    # calculates pro rata for the first period
    def subtotal_amount
      to_pro_rated_money(super)
    end

    def host_service_fee
      to_pro_rated_money(super)
    end

    def guest_service_fee
      to_pro_rated_money(super)
    end

    protected

    def to_pro_rated_money(amount)
      Money.new((amount.cents * pro_rata).ceil, @recurring_booking.currency)
    end

    def pro_rata
      @pro_rata ||= (@recurring_booking.next_charge_date.end_of_month.day - @recurring_booking.next_charge_date.day + 1) / @recurring_booking.next_charge_date.end_of_month.day.to_f
    end
  end

end
