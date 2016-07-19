module OrdersHelper
  def path_to_orders(options={})
    url_for(action: :index, state: options[:state])
  end
end
