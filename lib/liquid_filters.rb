module LiquidFilters
  include MoneyRails::ActionViewExtension
  include CurrencyHelper
  include ActionView::Helpers::NumberHelper

  def shorten_url(url)
    if DesksnearMe::Application.config.googl_api_key.present?
      Googl.shorten(url, nil, DesksnearMe::Application.config.googl_api_key).short_url
    else
      Googl.shorten(url).short_url
    end
  end

  def in_groups_of(array, integer)
    array.in_groups_of(integer)
  end

  def pluralize(string)
    string.try(:pluralize)
  end

  def location_path(transactable_type, location)
    Rails.application.routes.url_helpers.transactable_type_location_path(transactable_type.id, location.slug)
  end

  def lowest_price_without_cents_with_currency(object, lgpricing_filters = [])
    lgpricing_filters ||= []
    prices = object.lowest_price(lgpricing_filters)
    if prices
      periods = {monthly: 'month', weekly: 'week', daily: 'day', hourly: 'hour'}
      { 'price' => self.price_without_cents_with_currency(prices[0]), 'period' =>  periods[prices[1]] }
    else
      {}
    end
  end

  def lowest_price_with_cents_with_currency(object, lgpricing_filters = [])
    prices = object.lowest_price(lgpricing_filters)
    if prices
      periods = {monthly: 'month', weekly: 'week', daily: 'day', hourly: 'hour'}
      { 'price' => self.price_with_cents_with_currency(prices[0]), 'period' =>  periods[prices[1]] }
    else
      {}
    end
  end

  def connections_for(listing, current_user)
    return [] if current_user.nil? || current_user.friends.count.zero?

    friends = current_user.friends.visited_listing(listing).collect do |user|
      "#{user.name} worked here";
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

  def connections_tooltip(connections, size = 5)
    difference = connections.size - size
    connections = connections.first(5)
    connections << t('search.list.additional_social_connections', count: difference) if difference > 0
    connections.join('<br />').html_safe
  end

  def price_without_cents_with_currency(money)
    money_without_cents_and_with_symbol(money)
  end

  def price_with_cents_with_currency(money)
    humanized_money_with_symbol(money)
  end

  def space_listing_placeholder_path(height, width)
    ActionController::Base.helpers.asset_url(Placeholder.new(height: height.to_i, width: width.to_i).path)
  end

  def translate_property(property, target_acting_as_set)
    if Transactable::DEFAULT_ATTRIBUTES.include? property
      # These are the hard coded attributes that have their own column on the transactables table
      translate("simple_form.labels.transactable.#{property}")
    else
      # These are the custom attributes added by the MPO
      translate("simple_form.labels.#{target_acting_as_set.translation_key_suffix}.#{property}")
    end
  end

  def translate(key, options={})
    I18n.t(key, options.deep_symbolize_keys)
  end
  alias_method :t, :translate

  def filter_text(text = '')
    return '' if text.blank?
    if PlatformContext.current.instance.apply_text_filters
      @text_filters ||= TextFilter.pluck(:regexp, :replacement_text, :flags)
      @text_filters.each { |text_filter| text.gsub!(Regexp.new(text_filter[0].strip, text_filter[2]), text_filter[1]) }
      text
    else
      text
    end
  end

  def custom_sanitize(html = '')
    return '' if html.blank?
    html.gsub!("\r\n", "<br />")
    if PlatformContext.current.instance.custom_sanitize_config.present?
      @custom_sanitizer ||= CustomSanitizer.new(PlatformContext.current.instance.custom_sanitize_config)
      @custom_sanitizer.sanitize(html).html_safe
    else
      html
    end
  end

end

