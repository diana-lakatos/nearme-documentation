class InstanceAdmin::Analytics::OverviewController < InstanceAdmin::Analytics::BaseController
  def show
    @last_month_listings = Transactable.select('COUNT(transactables.*) AS listings_count, DATE(transactables.created_at) AS listing_date, transactable_type_id').where('DATE(transactables.created_at) >= ?', Date.current - 30.days).order('listing_date ASC').group('transactable_type_id, listing_date')
    @listings_chart = ChartDecorator.decorate(@last_month_listings, :last_30_days, labels_max_count: 31)

    @last_month_revenue = Payment.where(payable_type: 'Reservation').paid.last_x_days(30)
                          .order('created_at ASC')
    @revenue_chart = ChartDecorator.decorate(@last_month_revenue, :last_30_days, labels_max_count: 31)

    @last_month_bookings = Reservation.last_x_days(30).order('created_at ASC')
    @bookings_chart = ChartDecorator.decorate(@last_month_bookings, :last_30_days, labels_max_count: 31)
  end
end
