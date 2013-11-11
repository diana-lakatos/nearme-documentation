require 'money-rails'

module ReservationsHelper

  def location_query_string(location = @location)
    query = [location.state, location.city, location.country]
    query.reject! { |item| !item.present? || item == "Unknown" }
    query.join('%2C+')
  end

  def reservation_navigation_link(action)
    (link_to(content_tag(:span, action.titleize), self.send("#{action}_reservations_path"), :class => "upcoming-reservations btn btn-medium btn-gray#{action==params[:action] ? " active" : "-darker"}")).html_safe
  end

  def upcoming_reservation_count
    @upcoming_reservation_count ||= current_user.reservations.not_archived.count
  end

  def archived_reservation_count
    @archived_reservation_count ||= current_user.reservations.archived.count
  end

  def secure_listing_url(listing, options = {})
    if Rails.env.production?
      options = options.reverse_merge(protocol: "https://")
    end

    listing_reservations_url(listing, options)
  end

end