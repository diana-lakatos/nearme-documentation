module LiquidFilters
  include MoneyRails::ActionViewExtension
  include CurrencyHelper
  include ActionView::Helpers::NumberHelper
  include WillPaginate::ViewHelpers
  include ActionView::Helpers::UrlHelper

  def shorten_url(url)
    if DesksnearMe::Application.config.googl_api_key.present?
      Googl.shorten(url, nil, DesksnearMe::Application.config.googl_api_key).short_url
    else
      Googl.shorten(url).short_url
    end
  rescue e
    if Rails.env.production?
      raise e
    else
     'http://limitreached'
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
      periods = {
        monthly: t('periods.month'),
        weekly: t('periods.week'),
        daily: object.try(:overnight_booking?) ? t('periods.night') : t('periods.day'),
        hourly: t('periods.hour'),
        weekly_subscription: t('periods.week'),
        monthly_subscriptiont: ('periods.month')
      }
      { 'price' => self.price_without_cents_with_currency(prices[0]), 'period' =>  periods[prices[1]] }
    else
      object.try(:action_free_booking?) ? { 'free' => true } : {}
    end
  end

  def lowest_price_with_cents_with_currency(object, lgpricing_filters = [])
    prices = object.lowest_price(lgpricing_filters)
    if prices
      periods = {monthly: t('periods.month'), weekly: t('periods.week'), daily: object.try(:overnight_booking?) ? t('periods.night') : t('periods.day'), hourly: t('periods.hour')}
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
      translate("#{target_acting_as_set.translation_namespace}.labels.#{property}")
    end
  end

  def humanize(key)
    key.try(:humanize)
  end

  def translate(key, options={})
    I18n.t(key, options.deep_symbolize_keys)
  end
  alias_method :t, :translate

  def localize(datetime, format = 'long')
    datetime = datetime.to_date if datetime.is_a?(String)
    I18n.l(datetime, format: format.to_sym)
  end
  alias_method :l, :localize

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

  def pagination_links(collection)
    will_paginate collection,
                  controller: @context.registers[:controller],
                  renderer: 'LiquidLinkRenderer'
  end

  def request_parameter(method)
    if @context.registers[:controller].request.respond_to?(method)
      @context.registers[:controller].request.send(method.to_sym)
    end
  end

  def image_url(path_to_file)
    ActionController::Base.helpers.image_url(path_to_file)
  end

  def videoify(url = '')
    return url if url.blank?
    VideoEmbedder.new(url).html.html_safe
  end

  def json(object)
    object.to_json
  end

  def sha1(object)
    Digest::SHA1.hexdigest object
  end

  def tag_filter_link(tag, custom_classes=[])
    params = @context.registers[:controller].params
    current_filters = params[:tags].try(:split, ",").presence || []

    if current_filters.try(:include?, tag.slug).presence
      filters_without_current = (current_filters - [tag.slug]).join(",")

      href = "?tags=#{filters_without_current}"
      classes = %w(add selected)
    else
      filters = (current_filters + [tag.slug]).uniq.join(",")

      href = "?tags=#{filters}"
      classes = %w(add)
    end

    classes.push(custom_classes).flatten!.uniq! if custom_classes.present?

    link_to(tag.name, href, class: classes.join(" "))
  end
end
