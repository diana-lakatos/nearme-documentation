class InstanceAdmin::AnalyticsController < InstanceAdmin::BaseController

  def index
    @last_month_listings = platform_context.instance.listings.select('COUNT(listings.*) AS listings_count, DATE(listings.created_at) AS listing_date').where('DATE(listings.created_at) >= ?', Date.current - 30.days).order('listing_date ASC').group('listing_date')
    @listings_chart = ChartDecorator.decorate(@last_month_listings, :last_30_days, { :labels_max_count => 31 })

    @last_month_revenue = platform_context.instance.reservation_charges.paid.last_x_days(30).
      order('created_at ASC')
    @revenue_chart = ChartDecorator.decorate(@last_month_revenue, :last_30_days, { :labels_max_count => 31 })

    @last_month_bookings = platform_context.instance.reservations.last_x_days(30).order('created_at ASC')
    @bookings_chart = ChartDecorator.decorate(@last_month_bookings, :last_30_days, { :labels_max_count => 31 })
  end

end
