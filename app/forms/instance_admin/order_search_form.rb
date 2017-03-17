# frozen_string_literal: true
class InstanceAdmin::OrderSearchForm < SearchForm
  property :user_type, virtual: true
  property :buyer_name, virtual: true
  property :seller_name, virtual: true
  property :order_state, virtual: true
  property :payment_type, virtual: true
  property :sort_by_date, virtual: true
  property :sort_by_total_paid, virtual: true

  def initialize
    super Object.new
  end

  def to_search_params
    result = {}

    result[:by_buyer_name] = buyer_name if buyer_name.present?

    result[:by_seller_name] = seller_name if seller_name.present?

    result[:by_order_state] = order_state if order_state.present?

    if payment_type == 'free'
      result[:free_orders] = nil
    elsif payment_type == 'paid'
      result[:non_free_orders] = nil
    end

    result[:sorted_by_date] = sort_by_date if sort_by_date.present?

    result[:sorted_by_total_paid] = sort_by_total_paid if sort_by_total_paid.present?

    result
  end
end
