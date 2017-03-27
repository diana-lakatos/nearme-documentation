# frozen_string_literal: true
module ListingsHelper
  def listing_inline_description(listing, length = 65)
    raw(truncate(strip_tags(listing.company_description), length: length))
  end

  # Listing data for initialising a client-side bookings module
  def listing_booking_data(listing)
    base_data = {
      id: listing.id,
      name: listing.name,
      review_url: review_listing_reservations_url(listing),
      subunit_to_unit_rate: Money::Currency.new(listing.currency).subunit_to_unit,
      quantity: listing.quantity,
      initial_bookings: @initial_bookings,
      zone_offset: listing.zone_utc_offset,
      timezone_info: listing.timezone_info
    }
    base_data.merge!(listing.action_type.booking_module_options)
    base_data
  end

  def strip_http(url)
    url.gsub(/https?:\/\/(www\.)?/, '').gsub(/\/$/, '')
  end

  def listing_data_attributes(listing = @listing)
    {
      'data-listing-id': listing.id
    }
  end

  def selected_listing_siblings(location, listing, user = current_user)
    @siblings ||= (user && user.companies.first == location.company ? location.listings.active : location.listings.visible) - [listing]
  end

  def space_listing_placeholder_path(options = {})
    Placeholder.new(height: options[:height], width: options[:width]).path
  end

  def connection_tooltip_for(connections, size = 5)
    difference = connections.size - size
    connections = connections.first(5)
    connections << t('search.list.additional_social_connections', count: difference) if difference > 0
    connections.join('<br />').html_safe
  end

  def connections_for(listing, current_user)
    find_connections_for(listing, current_user)
  end

  # TODO: remove after switching to FormConfiguration
  def get_availability_template_object(parent)
    if parent.availability_template && parent.custom_availability_template?
      parent.availability_template
    elsif parent.availability_templates.any?
      parent.availability_templates.first_or_initialize do |at|
        at.availability_rules ||= [AvailabilityRule.new]
      end
    elsif parent.availability_template
      duplicate_template(parent, parent.availability_template)
    elsif parent&.default_availability_template
      duplicate_template(parent, parent.default_availability_template)
    else
      parent.availability_templates.new do |at|
        at.availability_rules = [AvailabilityRule.new]
      end
    end
  end

  # TODO: remove after switching to FormConfiguration
  def duplicate_template(parent, template)
    parent.availability_template = template.dup
    parent.availability_template.availability_rules = template.availability_rules.map(&:dup)
    parent.availability_template
  end

  def link_to_activity_feed_object(text, object, *options, &block)
    text = capture(&block) if block_given?
    if object.is_a?(Transactable)
      link_to(text, object.decorate.show_path, *options)
    elsif object.is_a?(User)
      link_to(text, object.decorate.show_path)
    else
      link_to(text, object, *options)
    end
  end

  def form_url_to_project(transactable_type, transactable)
    if transactable.new_record?
      dashboard_project_type_projects_path(project_type_id: transactable_type.id)
    else
      dashboard_project_type_project_path(project_type_id: transactable_type.id, id: transactable.id)
    end
  end

  private

  def find_connections_for(listing, current_user)
    return [] if current_user.nil? || current_user.friends.count.zero?

    friends = current_user.friends.visited_listing(listing).collect do |user|
      "#{user.name} worked here"
    end

    hosts = current_user.friends.hosts_of_listing(listing).collect do |user|
      "#{user.name} is the host"
    end

    host_friends = current_user.friends_know_host_of(listing).collect do |user|
      "#{user.name} knows the host"
    end

    mutual_visitors = current_user.mutual_friends.visited_listing(listing).collect do |user|
      next unless user.mutual_friendship_source
      "#{user.mutual_friendship_source.name} knows #{user.name} who worked here"
    end

    [friends, hosts, host_friends, mutual_visitors].flatten
  end

  def dimensions_templates_collection
    (@platform_context.instance.dimensions_templates + current_user.dimensions_templates).map do |dt|
      ["#{dt.name} (#{dt.height} #{t(dt.height_unit, scope: 'measure_units.length')} x #{dt.width} #{t(dt.width_unit, scope: 'measure_units.length')} x #{dt.depth} #{t(dt.depth_unit, scope: 'measure_units.length')}, #{dt.weight} #{t(dt.weight_unit, scope: 'measure_units.weight')})", dt.id]
    end
  end
end
