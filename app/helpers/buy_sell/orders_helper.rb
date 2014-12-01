module BuySell::OrdersHelper
  def orders_navigation_link(state)
    link_to(content_tag(:span, state.titleize), orders_path(state: state),
      class: [
        'upcoming-reservations',
        'btn btn-medium',
        "btn-gray#{state==(params[:state] || 'new') ? " active" : "-darker"}"
      ]).html_safe
  end
end
