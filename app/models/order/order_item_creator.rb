# frozen_string_literal: true
class Order
  class OrderItemCreator
    PERMITTED_FREQUENCY_UNITS = %w(hour day month).freeze

    def initialize(order)
      @order = order
      @period = order.periods.first
      @last_order_item = order.order_items.last
    end

    def create
      @last_order_item = @order.order_items.create!(order_item_attributes)
      GeneratePaymentJob.perform_later(@last_order_item.starts_at.end_of_day, @last_order_item.class.name, @last_order_item.id)
      @order.update_attributes!(generate_order_item_at: next_period_starts_at) if @order.is_recurring?
      @last_order_item
    end

    private

    def order_item_attributes
      {
        starts_at: next_period_starts_at,
        ends_at: next_period_ends_at,
        currency: @order.currency,
        order: @order
      }
    end

    def next_period_starts_at
      next_period_at(@period.start_minute)
    end

    def next_period_ends_at
      next_period_at(@period.end_minute)
    end

    def next_period_at(minute)
      next_period_date.in_time_zone(@order.time_zone).change(hour: minute / 60, minute: minute % 60)
    end

    def next_period_date
      return @period.date if !@order.is_recurring? || @last_order_item.blank?
      @last_order_item.starts_at.to_date + @period.recurring_frequency.send(frequency_unit)
    end

    def frequency_unit
      raise 'Unpermitted frequency unit' unless PERMITTED_FREQUENCY_UNITS.include?(@period.recurring_frequency_unit)
      @period.recurring_frequency_unit
    end
  end
end
