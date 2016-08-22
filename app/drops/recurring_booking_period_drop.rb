class RecurringBookingPeriodDrop < BaseDrop
  include CurrencyHelper
  attr_reader :source

  delegate :id, :line_items, :created_at, :payment, :total_amount_cents, :pending?,
    :approved?, :rejected?, :state, :order, :persisted?, :rejection_reason, to: :source

  def payment_state
    @source.payment.try(:state) || 'unpaid'
  end

  def formatted_total_amount
    humanized_money_with_cents_and_symbol(@source.total_amount)
  end

  def rejection_form_path
    routes.rejection_form_dashboard_company_order_order_item_path(@source.order, @source)
  end

  def show_url
    '/dashboard/order_items'
    #urlify(routes.dashboard_company_order_items_path)
  end

end
