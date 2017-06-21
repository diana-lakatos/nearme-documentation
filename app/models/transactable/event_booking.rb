class Transactable::EventBooking < Transactable::ActionType
  has_one :schedule, as: :scheduable, dependent: :destroy, inverse_of: :scheduable
  has_one :pricing, as: :action

  accepts_nested_attributes_for :schedule, allow_destroy: true

  before_validation :pass_time_zone_to_schedule

  validates :schedule, presence: true
  validates :pricings, presence: true, if: :enabled?
  validates_associated :pricings, if: :enabled?

  delegate :only_exclusive_price_available?, :book_it_out_available?,
           :exclusive_price_available?, :is_free_booking?, :price, :unit, to: :pricing

  def available_prices
    pricing.price_information
  end

  def schedule_availability
    next_available_occurrences(500, end_date: 6.months.from_now).map { |o| o[:occures_at] }
  end

  def open_on?(date, start_min = nil, _end_min = nil)
    hour = start_min / 60
    minute = start_min - (60 * hour)
    Time.use_zone(time_zone) do
      t = Time.zone.parse("#{date} #{hour}:#{minute}")
      return false if schedule.schedule_exception_ranges(t).any? { |range| range.cover?(occurrence) }
      schedule.schedule.occurs_between?(t - 1.second, t) || schedule.schedule.occurs_on?(t)
    end
  end

  def next_available_occurrences(number_of_occurrences = 10, params = {})
    return [] if schedule.nil?
    occurrences = []
    Time.use_zone(time_zone) do
      if params[:page].to_i <= 1
        @start_date = params[:start_date].try(:to_date).try(:beginning_of_day)
      else
        @start_date = Time.at(params[:last_occurrence].to_i)
      end
      time_now = Time.now.in_time_zone(time_zone)
      @start_date = time_now if @start_date.nil? || @start_date < time_now
      end_date = params[:end_date].try(:to_date).try(:end_of_day)
      exception_ranges = schedule.schedule_exception_ranges(@start_date)
      schedule.schedule.send(:enumerate_occurrences, @start_date + 1, end_date).each do |occurrence|
        next if schedule.unavailable_period_enabled && exception_ranges.any? { |range| range.cover?(occurrence) }
        start_minute = occurrence.min + (60 * occurrence.hour)
        availability = quantity.to_i - desks_booked_on(occurrence.to_datetime, start_minute, start_minute)
        if availability > 0
          occurrences << { id: occurrence.to_i, text: I18n.l(occurrence.in_time_zone(time_zone), format: :long), availability: availability.to_i, occures_at: occurrence }
        end
        break if occurrences.size == number_of_occurrences
      end
    end

    occurrences
  end

  def bookable?
    schedule.present? && next_available_occurrences(1).any?
  end

  def booking_module_options
    super.merge(fixed_price_cents: pricing.price_cents,
                booking_type: 'schedule').merge(pricing.availabile_discounts)
  end

  def price_calculator(order)
    Reservation::FixedPriceCalculator.new(order)
  end

  private

  def pass_time_zone_to_schedule
    schedule.try(:time_zone=, transactable.time_zone)
  end
end
