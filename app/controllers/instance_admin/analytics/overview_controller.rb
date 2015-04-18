class InstanceAdmin::Analytics::OverviewController < InstanceAdmin::Analytics::BaseController

  def show
    @last_month_listings = Transactable.select('COUNT(transactables.*) AS listings_count, DATE(transactables.created_at) AS listing_date, transactable_type_id').where('DATE(transactables.created_at) >= ?', Date.current - 30.days).order('listing_date ASC').group('transactable_type_id, listing_date')
    @listings_chart = ChartDecorator.decorate(@last_month_listings, :last_30_days, { :labels_max_count => 31 })

    @last_month_revenue = Payment.where(payable_type: 'Reservation').paid.last_x_days(30).
      order('created_at ASC')
    @revenue_chart = ChartDecorator.decorate(@last_month_revenue, :last_30_days, { :labels_max_count => 31 })

    @last_month_bookings = Reservation.last_x_days(30).order('created_at ASC')
    @bookings_chart = ChartDecorator.decorate(@last_month_bookings, :last_30_days, { :labels_max_count => 31 })
  end

  def products
    # product_type_id is not used for the chart but is required by some plugin, likely has_custom_attributes
    @last_month_products = Spree::Product.select('COUNT(spree_products.*) AS products_count, DATE(spree_products.created_at) AS product_date, null as product_type_id').where('DATE(spree_products.created_at) >= ?', Date.current - 30.days).order('product_date ASC').group('product_date')
    @products_chart = ChartDecorator.decorate(@last_month_products, :last_30_days, { :labels_max_count => 31 })

    @last_month_revenue = Payment.where(payable_type: 'Spree::Order').paid.last_x_days(30).
      order('created_at ASC')
    @revenue_chart = ChartDecorator.decorate(@last_month_revenue, :last_30_days, { :labels_max_count => 31 })

    @last_month_sales = Spree::Order.select('COUNT(spree_orders.*) AS orders_count, DATE(spree_orders.created_at) AS orders_date').where('DATE(spree_orders.created_at) >= ?', Date.current - 30.days).order('orders_date ASC').group('orders_date')
    @sales_chart = ChartDecorator.decorate(@last_month_sales, :last_30_days, { :labels_max_count => 31 })
  end

end

