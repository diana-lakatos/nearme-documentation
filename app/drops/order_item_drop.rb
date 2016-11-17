# frozen_string_literal: true
class OrderItemDrop < BaseDrop
  # @todo Investigate this, path is invalid
  def show_url
    '/order_items'
    # urlify(routes.dashboard_company_order_items_path)
  end
end
