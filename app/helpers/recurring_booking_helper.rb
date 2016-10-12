module RecurringBookingHelper
  def recurring_booking_navigation_link(action)
    (link_to(content_tag(:span, action.titleize), send("#{action}_recurring_bookings_path"), class: "upcoming-reservations btn btn-medium btn-gray#{action == params[:action] ? ' active' : '-darker'}")).html_safe
  end

  def upcoming_recurring_booking_count
    @upcoming_recurring_booking_count ||= current_user.recurring_bookings.not_archived.count
  end

  def archived_recurring_booking_count
    @archived_recurring_booking_count ||= current_user.recurring_bookings.archived.count
  end

  def secure_recurring_listing_url(listing, options = {})
    if Rails.env.production?
      options = options.reverse_merge(protocol: 'https://')
    end

    listing_recurring_bookings_url(listing, options)
  end
end
