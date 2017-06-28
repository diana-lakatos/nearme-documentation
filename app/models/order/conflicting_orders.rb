# frozen_string_literal: true
class Order::ConflictingOrders
  attr_accessor :scope

  def initialize(order: nil, dates: [], transactable: nil, start_minute: nil, end_minute: nil, is_recurring: nil, quantity: nil)
    if @order = order
      @quantity = @order.quantity
      @start_minute = @order.periods.first.start_minute
      @end_minute = @order.periods.first.end_minute
      @transactable = @order.transactable
      @is_recurring = @order.is_recurring?
      @dates = @order.periods.map(&:date)
    else
      @quantity = quantity
      @start_minute = start_minute
      @end_minute = end_minute
      @transactable = transactable
      @is_recurring = is_recurring
      @dates = dates
    end
    @scope = scope_base
  end

  def get_scope
    query = if @is_recurring
              'reservation_periods.date in (:dates) or (EXTRACT(DOW FROM reservation_periods.date) = :wdays)'
            else
              'reservation_periods.date in (:dates) or (reservation_periods.recurring_frequency = 7 and EXTRACT(DOW FROM reservation_periods.date) in (:wdays))'
            end
    @scope = scope.where(query, dates: @dates, wdays: @dates.map(&:wday))
    add_time_scope

    @scope
  end

  def by_quantity
    get_scope.where('orders.quantity + ? > ?', @quantity, @transactable.quantity)
  end

  def scope_base
    Order.confirmed.joins(:periods).where(transactable_id: @transactable.id)
  end

  def add_time_scope
    if @start_minute
      hourly_values = {}
      hourly_conditions = ['(reservation_periods.start_minute IS NULL AND reservation_periods.end_minute IS NULL)']
      if @end_minute
        hourly_conditions << ['NOT isempty(int4range(reservation_periods.start_minute, reservation_periods.end_minute) * int4range(:start_minute, :end_minute))']
        hourly_values = { start_minute: @start_minute, end_minute: @end_minute }
      end

      @scope = @scope.where(hourly_conditions.join(' OR '), hourly_values)
    end
  end
end
