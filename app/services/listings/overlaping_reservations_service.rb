class Listings::OverlapingReservationsService
  attr_reader :listing, :warnings
  def initialize listing, date
    @listing = listing
    @date = date
    @warnings = {}
  end

  def valid?
    @warnings.clear

    overlaping_reservations.count.tap do |counter|
      @warnings.merge! 'overlaping_reservations' => I18n.t(:overlapping_reservations, scope: [:warnings, :reservations], counter: counter) unless counter.zero?
    end

    @warnings.empty?
  end

  private

  def overlaping_reservations
    listing.reservations
      .confirmed
      .joins(:periods)
      .where(sql_query, @date)
  end

  def sql_query
    'reservation_periods.date = :date'
  end
end
