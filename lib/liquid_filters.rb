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
    Rails.application.routes.url_helpers.transactable_type_location_path(transactable_type.slug, location.slug)
  end

  def lowest_price_without_cents_with_currency(object, lgpricing_filters = [])
    get_lowest_price_with_options(object, lgpricing_filters)
  end

  def lowest_full_price_without_cents_with_currency(object, lgpricing_filters = [])
    get_lowest_price_with_options(object, lgpricing_filters, :full_price => true)
  end

  def lowest_full_price_with_cents_with_currency(object, lgpricing_filters = [])
    get_lowest_price_with_options(object, lgpricing_filters, :full_price => true, :with_cents => true)
  end

  def get_lowest_price_with_options(object, lgpricing_filters, options = {})
    lgpricing_filters ||= []

    if options[:full_price]
      prices = object.lowest_full_price(lgpricing_filters)
    else
      prices = object.lowest_price(lgpricing_filters)
    end

    if prices
      periods = {
        monthly: I18n.t('periods.month'),
        weekly: I18n.t('periods.week'),
        daily: object.try(:overnight_booking?) ? I18n.t('periods.night') : I18n.t('periods.day'),
        hourly: I18n.t('periods.hour'),
        weekly_subscription: I18n.t('periods.week'),
        monthly_subscription: I18n.t('periods.month')
      }

      if options[:with_cents]
        { 'price' => self.price_with_cents_with_currency(prices[0]), 'period' =>  periods[prices[1]] }
      else
        { 'price' => self.price_without_cents_with_currency(prices[0]), 'period' =>  periods[prices[1]] }
      end
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

  def price_with_cents_with_currency(money)
    humanized_money_with_symbol(money)
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

  def pagination_links(collection, options = {})
    opts = {
      controller: @context.registers[:controller],
      renderer: 'LiquidLinkRenderer'
    }.merge(options.symbolize_keys)
    will_paginate collection, opts
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

  # Renders search_box with options
  # tt_names - Transactable Type names separated by ','
  # class_name - additional CSS class name
  # inputs - what inputs should be displayed: geolocation, fulltext, categories, datepickers. Separated by ','
  def search_box_for(tt_names, class_name = '', inputs = '')
    names = tt_names.split(',').map(&:strip)
    tt = TransactableType.where(name: names) + InstanceProfileType.where(name: names)
    if tt.any?
      ordered = {}
      tt.map{|searchable| ordered[names.index(searchable.name)] = searchable}
      ordered = ordered.sort.to_h
      @context.registers[:action_view].render 'home/search_box_inputs.html',
        transactable_types: ordered.values,
        custom_search_inputs: inputs.split(',').map(&:strip),
        class_name: class_name + ' search-box-liquid-tag',
        transactable_type_picker: ordered.values.many?
    else
      "No Service or Product type with names: #{tt_names}"
    end
  end

  # Renders search_button with options
  # tt_name - Transactable Type name
  # class_name - additional CSS class name
  def search_button_for(tt_name, class_name = '')
    if tt = TransactableType.find_by(name: tt_name.strip) || tt = InstanceProfileType.find_by(name: tt_name.strip)
      @context.registers[:action_view].render 'home/search_button_tag.html',
        transactable_type: tt,
        class_name: class_name + ' search-box-liquid-tag'
    else
      "No Service or Product type with name: #{tt_name}"
    end
  end

  # Returns url for url helper name and arguments
  def generate_url(url_name, *args)
    Rails.application.routes.url_helpers.try(url_name, args)
  end
end
