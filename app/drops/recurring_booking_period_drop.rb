class RecurringBookingPeriodDrop < BaseDrop
  include CurrencyHelper

  # @return [RecurringBookingPeriodDrop]
  attr_reader :source

  # @!method id
  #   @return [Integer] numeric identifier for the recurring booking period
  # @!method line_items
  #   @return [Array<LineItemDrop>] line items associated with this recurring booking period
  # @!method created_at
  #   @return [DateTime] time when the recurring booking period was created
  # @!method payment
  #   @return [PaymentDrop] payment object associated with this recurring booking period
  # @!method total_amount_cents
  #   @return [BigDecimal] total cents amount for this recurring booking period
  # @!method pending?
  #   @return [Boolean] whether the object is in the pending state
  # @!method approved?
  #   @return [Boolean] whether the object is in the approved state
  # @!method rejected?
  #   @return [Boolean] whether the object is in the rejected state
  # @!method state
  #   @return [String] the current state of the object
  # @!method order
  #   @return [OrderDrop] Order object to which this period belongs to
  # @!method persisted?
  #   @return [Boolean] whether the object is saved in the database
  # @!method rejection_reason
  #   @return [String] rejection reason for this period object if present
  delegate :id, :line_items, :created_at, :payment, :total_amount_cents, :pending?,
           :approved?, :rejected?, :state, :order, :persisted?, :rejection_reason, to: :source

  # @return [String] payment state for this period
  def payment_state
    return 'paid' if @source.paid?
    @source.pending? ? @source.state : (@source.payment.try(:state) || 'unpaid')
  end

  # @return [String] total amount for this period formatted using the global currency
  #   formatting rules
  def formatted_total_amount
    render_money(@source.total_amount)
  end

  # @return [String] path to the rejection form for this period
  def rejection_form_path
    routes.rejection_form_dashboard_company_order_order_item_path(@source.order, @source)
  end

  # @return [String] url to managing recurring booking periods
  # @todo Path/url inconsistency
  def show_url
    '/dashboard/order_items'
    # urlify(routes.dashboard_company_order_items_path)
  end

  # @return [RecurringBookingDrop] recurring booking (order) associated with this period
  def recurring_booking
    @source.order
  end
end
