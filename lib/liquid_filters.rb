# frozen_string_literal: true
require 'googl'
require 'sanitize'

module LiquidFilters
  include MoneyRails::ActionViewExtension
  include CurrencyHelper
  include ActionView::Helpers::NumberHelper
  include WillPaginate::ViewHelpers
  include ActionView::Helpers::UrlHelper
  include ActionView::RecordIdentifier
  include ActionView::Helpers::DateHelper

  def shorten_url(url)
    if DesksnearMe::Application.config.googl_api_key.present?
      Googl.shorten(url, nil, DesksnearMe::Application.config.googl_api_key).short_url
    else
      Googl.shorten(url).short_url
    end
  rescue StandardError => e
    if Rails.env.production?
      MarketplaceLogger.error('Url Shortening Error', e.to_s + ' :: ' + url, raise: false)
      ''
    else
      'http://limitreached'
    end
  end

  def no_footer!
    @no_footer = true
  end

  def active_class(arg1, arg2, class_name = 'active')
    class_name if arg1 == arg2
  end

  def is_included_in_array(array, el)
    array.include?(el)
  end

  def in_groups_of(array, integer)
    array.in_groups_of(integer)
  end

  def pluralize(string)
    string.try(:pluralize)
  end

  def compact(array)
    array.compact
  end

  def reverse(array)
    array.reverse
  end

  def add_to_array(array, item)
    array ||= []
    array << item
    array
  end

  def rotate(array, count = 1)
    array.rotate(count)
  end

  def location_path(_transactable_type, location)
    return '' if location.blank?
    location.listings.searchable.first.try(:decorate).try(:show_path)
  end

  def lowest_price_without_cents_with_currency(object, lgpricing_filters = [])
    get_lowest_price_with_options(object, lgpricing_filters)
  end

  def lowest_full_price_without_cents_with_currency(object, lgpricing_filters = [])
    get_lowest_price_with_options(object, lgpricing_filters, full_price: true)
  end

  def lowest_full_price_with_cents_with_currency(object, lgpricing_filters = [])
    get_lowest_price_with_options(object, lgpricing_filters, full_price: true, with_cents: true)
  end

  def get_lowest_price_with_options(object, lgpricing_filters, options = {})
    lgpricing_filters ||= []

    pricing = if options[:full_price]
                object.lowest_full_price(lgpricing_filters)
              else
                object.lowest_price(lgpricing_filters)
              end

    if pricing.nil? || pricing.is_free_booking?
      { 'free' => true }
    else
      if options[:with_cents]
        { 'price' => price_with_cents_with_currency(pricing.price) }
      else
        { 'price' => price_without_cents_with_currency(pricing.price) }
      end.merge('period' => pricing.decorate.units_translation('search.per_unit_price', 'search'))
    end
  end

  def lowest_price_with_cents_with_currency(object, lgpricing_filters = [])
    pricing = object.lowest_price(lgpricing_filters)
    if pricing
      { 'price' => price_with_cents_with_currency(pricing.price), 'period' => pricing.decorate.units_translation('search.per_unit_price', 'search') }
    else
      {}
    end
  end

  def connections_for(listing, current_user)
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

  def connections_tooltip(connections, size = 5)
    difference = connections.size - size
    connections = connections.first(5)
    connections << t('search.list.additional_social_connections', count: difference) if difference > 0
    connections.join('<br />').html_safe
  end

  def pricify(amount, currency = 'USD')
    render_money(amount.to_f.to_money(currency))
  end

  def price_with_cents_with_currency(money)
    render_money(money)
  end

  def price_without_cents_with_currency(money)
    render_money(money)
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

  def translate(key, options = {})
    I18n.t(key, options.deep_symbolize_keys)
  end
  alias t translate

  def localize(datetime, format = 'long')
    if datetime
      datetime = datetime.to_date if datetime.is_a?(String)
      I18n.l(datetime, format: format.to_sym)
    end
  end
  alias l localize

  def add_to_date(date, number_of_days)
    date + number_of_days.days
  end

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

  def parse_to_minute(string)
    time = parse_time(string)
    hour = time.strftime('%H')
    minute = time.strftime('%M')
    hour.to_i * 60 + minute.to_i
  end

  def to_date(datetime)
    datetime.try(:to_date)
  end

  def custom_sanitize(html = '')
    return '' if html.blank?

    html = nl2br(html)

    if PlatformContext.current.instance.custom_sanitize_config.present?
      @custom_sanitizer ||= CustomSanitizer.new(PlatformContext.current.instance.custom_sanitize_config)
      @custom_sanitizer.sanitize(html).html_safe
    else
      html
    end
  end

  def strip_tags(html = '')
    return '' if html.blank?
    @custom_sanitizer ||= CustomSanitizer.new
    @custom_sanitizer.strip_tags(html).html_safe
  end

  def nl2br(html = '')
    return '' if html.blank?
    html.gsub!("\r\n", '<br />')
    html
  end

  def pagination_links(collection, options = {})
    opts = {
      controller: @context.registers[:controller],
      renderer: 'LiquidLinkRenderer'
    }.merge(options.symbolize_keys)
    will_paginate collection, opts
  end

  def meta_attr(content)
    Sanitize.clean(content).gsub(/\s+/, ' ').strip
  end

  def request_parameter(method)
    @context.registers[:controller].request.send(method.to_sym) if @context.registers[:controller].request.respond_to?(method)
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

  def tag_filter_link(tag, custom_classes = [])
    params = @context.registers[:controller].params
    current_filters = params[:tags].try(:split, ',').presence || []

    if current_filters.try(:include?, tag.slug).presence
      filters_without_current = (current_filters - [tag.slug]).join(',')

      href = "?tags=#{filters_without_current}"
      classes = %w(add selected)
    else
      filters = (current_filters + [tag.slug]).uniq.join(',')

      href = "?tags=#{filters}"
      classes = %w(add)
    end

    classes.push(custom_classes).flatten!.uniq! if custom_classes.present?

    link_to(tag.name, href, class: classes.join(' '))
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
      tt.map { |searchable| ordered[names.index(searchable.name)] = searchable }
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
    return "unknown route #{url_name}" unless BaseDrop::RoutesProxy.respond_to_missing?(url_name)

    BaseDrop::RoutesProxy.public_send(url_name, *args)
  end

  # Changes text into datetime, for example today, 3 days ago etc.
  def parse_time(time)
    Chronic.parse(time)
  end

  # Make the text html_safe; mainly used for testing the
  # sanitization in Liquid::Variable to make sure that
  # html_safe text is not escaped
  def make_html_safe(html = '')
    html.html_safe
  end

  # Escape html; this is useful if you want to skip
  # using the CustomSanitizer that is applied normally
  def raw_escape_string(value)
    CGI.escapeHTML(value.to_s).html_safe
  end

  def already_favorite(user, object)
    return false unless user.present?
    user.default_wish_list.items.where(wishlistable_id: object.id, wishlistable_type: object.class_name).exists?
  end

  def titleize(text)
    text.titleize
  end

  def querify(hash)
    hash.to_query
  end

  def widget_links(path)
    return [] unless path.present?
    ReverseProxyLink.where(use_on_path: ::CGI.unescapeHTML(path.to_str))
  end

  def parameterize(text, separator = '-')
    text.parameterize(separator)
  end

  def find_collaborator(user, transactable)
    return false if user.try(:id).blank?
    transactable.transactable_collaborators.where(user: user.id).first
  end

  def find_collaborators_for_user_projects(current_user, user)
    user.source.transactable_collaborators.where(transactable_id: current_user.source.created_listings.with_state([:pending, :in_progress]).pluck(:id))
  end

  def is_approved_collaborator(user, transactable)
    return false if user.try(:id).blank?
    transactable.approved_transactable_collaborators.where(user: user.id).exists?
  end

  # alternative is to create WillPaginate::CollectionDrop, however when I tried it,
  # I could not iterate through collection. I tried adding all
  # instance methods found in documentation but it did not work,
  # so using this as a workaround. Probably one had to add all array's method as well
  def total_entries(will_paginate_collection)
    will_paginate_collection.total_entries
  end

  def get_enquirer_orders(user, transactable)
    transactable.line_item_orders.where(user_id: user.id).order('created_at ASC').active
  end

  def get_enquirer_confirmed_orders(user, transactable)
    transactable.line_item_orders.where(user_id: user.id).confirmed.order('created_at ASC')
  end

  def get_lister_orders(company, transactable)
    transactable.line_item_orders.where(company: company).order('created_at ASC')
  end

  def get_data_contents(external_id, options = {})
    data_source_contents = DataSourceContent.where('external_id like ?', external_id)
    data_source_contents.paginate(per_page: options[:per_page].presence || 10)
  end

  def is_visible(key)
    HiddenUiControls.find(key).visible?
  end

  def matches(string, regexp)
    !!(string =~ Regexp.new(regexp))
  end

  def get_payment_gateway_id(_str)
    PaymentGateway.with_credit_card.mode_scope.first.try(:id)
  end

  def map(object, method)
    object.map(&method.to_sym)
  end

  def strftime(date, format)
    date.strftime(format)
  end

  def to_money(amount, currency)
    Money.new(amount, currency)
  end

  def attachments_visible_for(transactable_drop, user_drop)
    transactable_drop.source.attachments_visible_for(user_drop.source)
  end

  def get_ckeditor_assets(access_level, options = {})
    sort_option = %w(created_at name).detect { |valid_key| options['sort'] == valid_key } || 'created_at'
    sort_direction = %w(asc desc).detect { |valid_key| options['direction'] == valid_key } || 'desc'
    Ckeditor::Asset.where(access_level: access_level)
                   .where('data_file_name LIKE ? OR title LIKE ?', "%#{options['query']}%", "%#{options['query']}%")
                   .order("#{sort_option} #{sort_direction}")
                   .paginate(page: options['page'] || 1, per_page: [(options['per_page'] || 10).to_i, 50].min)
  end
end
