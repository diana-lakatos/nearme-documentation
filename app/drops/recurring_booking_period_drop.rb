class RecurringBookingPeriodDrop < BaseDrop
  include CurrencyHelper
  attr_reader :source

  delegate :id, :line_items, :created_at, :payment, :total_amount_cents, :pending?,
    :approved?, :rejected?, :state, :order, :persisted?, to: :source

  def initialize(source)
    @source = source
  end

  def payment_state
    @source.payment.try(:state) || 'unpaid'
  end

  def formatted_total_amount
    humanized_money_with_cents_and_symbol(@source.total_amount)
  end

  def show_url
    '/order_items'
    #urlify(routes.dashboard_company_order_items_path)
  end

end
