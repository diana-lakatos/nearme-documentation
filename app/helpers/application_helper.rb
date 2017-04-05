# frozen_string_literal: true
require 'sanitize'

module ApplicationHelper
  include FormHelper
  include TooltipHelper
  include CurrencyHelper
  include FileuploadHelper
  include SharingHelper
  include CustomAttributes::ApplicationHelper
  include SearchEnginesStructuredDataHelper
  include TagListHelper
  include CommunityHelper
  include LoginLinksHelper

  def timeago(time)
    content_tag(:time, time, datetime: time.to_time.iso8601, class: :timeago)
  end

  def platform_context
    @platform_context_view ||= PlatformContext.current.decorate
  end

  def title(page_title, show_title = true)
    content_for(:title) { meta_attr(page_title.to_s) }
    @show_title = show_title
  end

  def canonical_url(url)
    content_for(:canonical_url) { url }
  end

  def meta_title(name)
    content_for(:meta_title) { meta_attr(name.to_s) }
  end

  def title_tag
    if home_page? && platform_context.theme.tagline.present?
      "#{platform_context.theme.meta_title} | #{platform_context.theme.tagline}"
    else
      raw([
        (show_title? ? content_for(:title) : nil),
        (additional_meta_title.present? ? additional_meta_title : nil)
      ].compact.join(' | '))
    end
  end

  def meta_attr(content)
    Sanitize.fragment(content.dup).gsub(/\s+/, ' ').strip.html_safe if content.present?
  end

  def meta_description(description)
    content_for(:meta_description) { meta_attr(description.to_s) }
  end

  def meta_description_content
    content_for?(:meta_description) ? meta_attr(content_for(:meta_description)) : meta_attr(platform_context.description || platform_context.name)
  end

  def additional_meta_title
    content_for?(:meta_title) ? meta_attr(content_for(:meta_title)) : meta_attr(platform_context.meta_title)
  end

  def canonical_prev_next(results)
    content_for(:next_canonical) { results.next_page.present? ? url_for(params.merge(page: results.next_page)) : nil }
    content_for(:prev_canonical) { results.previous_page.present? ? url_for(params.merge(page: results.previous_page)) : nil }
  end

  def show_title?
    @show_title
  end

  def meta_og_image_content
    content_for?(:meta_og_image) ? content_for(:meta_og_image) : platform_context.logo_image.url
  end

  def meta_og_image(image)
    content_for(:meta_og_image) { image }
  end

  def truncate_with_ellipsis(body, length, html_options = {})
    body ||= ''
    if body.size > length

      size = 0
      body = body.squish

      truncated_body = body.split.reject do |token|
        size += token.size + 1
        size > length
      end

      truncated_body_str = truncated_body.join(' ')
      truncated_body_regexp = Regexp.new("^#{Regexp.escape(truncated_body_str)}")
      excess_body = body.gsub(truncated_body_regexp, '').strip

      content_tag(:p, html_options) do
        truncated_body_str.html_safe +
          content_tag(:span, '&hellip;'.html_safe, class: 'truncated-ellipsis').html_safe +
          content_tag(:span, excess_body.html_safe, class: 'truncated-text hidden').html_safe
      end

    else
      body
    end
  end

  def link_to_registration(constraint, secured_constraint, secure_links, options = {}, &block)
    options[:rel] = nil if secure_links
    constraint.merge!(secured_constraint) if secure_links
    options[:data] ||= {}
    options[:data][:href] = new_api_user_path(constraint)
    link_to('#', options, &block)
  end

  def link_to_login(options = {}, &block)
    constraint = options[:url_options]
    options[:rel] = nil if secure_links?
    constraint.merge!(platform_context.secured_constraint) if secure_links?
    options[:data] ||= {}
    options[:data][:href] = new_user_session_url(constraint)
    link_to('#', options, &block)
  end

  def link_to_once(*args, &block)
    options = args.first || {}
    html_options = args.second || {}

    html_options[:disable_with] = 'Loading...' unless html_options.key?(:disable_with)
    if block_given?
      link_to(capture(&block), options, html_options)
    else
      link_to(options, html_options)
    end
  end

  def ico_for_flash(key)
    case key.to_s
    when 'notice'
      'ico-check'
    when 'success'
      'ico-check'
    when 'error'
      'ico-warning'
    when 'warning'
      'ico-warning'
    when 'deleted'
      'ico-close'
    end
  end

  def flash_key_name(key)
    case key.to_s
    when 'deleted'
      'warning'
    when 'error'
      'danger'
    when 'notice'
      'info'
    else
      key
    end
  end

  def array_to_unordered_list(arr = [])
    arr.map { |s| "<li>#{s}</li>" }.join.prepend('<ul>') << '</ul>'
  end

  def section_class(section_name = nil)
    [
      section_name,
      controller_name,
      "#{controller_name}-#{params[:action]}"
    ].compact.join(' ')
  end

  def theme_class(theme_name = nil)
    classes = [
      theme_name,
      controller_name,
      "#{controller_name}-#{params[:action]}"
    ]
    if current_user
      classes << 'user-role-lister' if current_user.seller_profile
      classes << 'user-role-enquirer' if current_user.buyer_profile
    end
    classes << "page-#{@page.id}-#{@page.slug}" if controller_name == 'pages' && params[:action] == 'show'

    classes.compact.join(' ')
  end

  def dnm_page_class
    [(content_for?(:top_sub_navigation) ? 'with-sub-navbar' : nil), (no_navbar? ? 'no-navbar' : nil)].compact.join(' ')
  end

  def distance_of_time_in_words_or_date(datetime)
    today = Date.current

    case datetime
    when DateTime, ActiveSupport::TimeWithZone, Time
      if datetime.to_date == today
        I18n.l(datetime, format: :short)
      elsif datetime.to_date == today.yesterday
        I18n.t('date.yesterday')
      else
        I18n.l(datetime.to_date, format: :short)
      end
    else
      ''
    end
  end

  def distance_of_time_in_words_or_date_in_time_zone(datetime, time_zone = 'UTC')
    Time.use_zone time_zone do
      distance_of_time_in_words_or_date(datetime.in_time_zone(time_zone))
    end
  end

  def render_olark?
    !(params[:controller] == 'locations' && params[:action] == 'show')
  end

  def nl2br(str)
    str.to_s.gsub(/\r\n|\r|\n/, '<br />').html_safe
  end

  def home_page?
    # the first condition has been added because /en [ where en was default language ] was returning true,
    # however /da was returning false, even though it was home page as well. This was causing issues with
    # homepage content / homepage css etc. The second condition is there just in case it was fixing other issue.
    # Btw: adding language: I18n.locale to second condition does not work :)
    params[:controller] == 'home' && params[:action] == 'index' || current_page?(controller: 'home', action: 'index')
  rescue
    false
  end

  def mask_phone_and_email_if_necessary(text)
    if PlatformContext.current.instance.apply_text_filters && text.present?
      @text_filters ||= TextFilter.pluck(:regexp, :replacement_text, :flags)
      @text_filters.each { |text_filter| text.gsub!(Regexp.new(text_filter[0].try(:strip), text_filter[2]), text_filter[1]) }
      text
    else
      text
    end
  end

  def custom_sanitze(html)
    if PlatformContext.current.instance.custom_sanitize_config.present?
      @custom_sanitizer ||= CustomSanitizer.new(PlatformContext.current.instance.custom_sanitize_config)
      @custom_sanitizer.sanitize(html).html_safe
    else
      html
    end
  end

  def orders_navigation_link(state)
    link_to(content_tag(:span, state.titleize), orders_path(state: state),
            class: [
              'upcoming-reservations',
              'btn btn-medium',
              "btn-gray#{state == (params[:state] || 'new') ? ' active' : '-darker'}"
            ]).html_safe
  end

  def user_menu_instance_admin_path(users_instance_admin)
    users_instance_admin = 'manage_blog' if users_instance_admin == 'blog'
    users_instance_admin = 'support_root' if users_instance_admin == 'support'
    main_app.send("instance_admin_#{users_instance_admin}_path")
  end

  def will_paginate_styled(collection, options = {})
    content_tag :div, class: 'pagination' do
      options[:renderer] = BuySellMarket::WillPaginateLinkRenderer::LinkRenderer
      options[:class] = ''
      will_paginate collection, options
    end
  end

  def will_paginate_dashboard(collection, options = {})
    options[:renderer] = BuySellMarket::WillPaginateDashboardLinkRenderer::LinkRenderer
    options[:class] = ''
    options[:inner_window] = 1
    options[:outer_window] = 0
    will_paginate collection, options
  end

  def active_class(arg1, arg2, class_name = 'active')
    class_name if arg1 == arg2
  end

  def hide_tab?(tab)
    key = "#{params[:controller]}/#{params[:action]}##{tab}"
    HiddenUiControls.find(key).hidden?
  end

  def admin_breadcrumbs
    if @breadcrumbs_title.present?
      @breadcrumbs_title.to_s
    else
      controller.class.to_s.deconstantize.demodulize
    end
  end

  def credit_card_date
    months = (1..12).map do |m|
      [m.to_s.rjust(2, '0'), m]
    end

    years = (Time.zone.now.year..(Time.zone.now + 15.years).year)
    { month: months, year: years }
  end

  def selected_date_value(date)
    Review::DATE_VALUES.each do |value|
      return I18n.t("instance_admin.manage.admin_searchable.#{value}") if value == date
    end
    date
  end

  def selected_account_standing(standing)
    return I18n.t("instance_admin.manage.admin_searchable.user.#{standing}") if User::ACCOUNT_STANDINGS.include?(standing.to_sym)
    standing
  end

  def selected_transactable_type(transactable_type_id, default_text = '')
    transactable_type = TransactableType.find_by(id: transactable_type_id)
    if transactable_type
      transactable_type.name
    else
      default_text
    end
  end

  def cache_expires_in_for(_cache_model = '')
    Rails.configuration.default_cache_expires_in
  end

  def i18n_cache_key(*args)
    args.compact + [PlatformContext.current.instance.context_cache_key.to_s, I18n.locale, PlatformContext.current.domain.name]
  end

  def cache_params_string
    request.query_parameters.to_a.sort_by { |el| el[0] }.map { |k, v| "#{k}=#{v}" }.join(',')
  end

  def is_i18n_set?(key)
    I18n.t(key, default: '').present?
  end

  def javascript_i18n_include_tag
    js_translations = I18n.t('js').to_json
    date_formats = %w(default day_month_year month_year short day_and_month only_date_short only_date full_day_month long).each_with_object({}) do |key, hash|
      hash[key] = I18n.t("date.formats.#{key}")
      hash
    end
    time_formats = %w(default short long with_time_zone day_and_month short_with_time_zone).each_with_object({}) do |key, hash|
      hash[key] = I18n.t("time.formats.#{key}")
      hash
    end
    datepicker_formats = %w(dformat).each_with_object({}) do |key, hash|
      hash[key] = I18n.t("datepicker.#{key}")
      hash
    end
    %(
      window.I18n = {};
      window.I18n.locale = '#{I18n.locale}';
      window.I18n.t = #{js_translations};
      window.I18n.dateFormats = #{date_formats.to_json};
      window.I18n.timeFormats = #{time_formats.to_json};
      window.I18n.datepickerFormats = #{datepicker_formats.to_json};
      window.I18n.abbrMonthNames = '#{Date::ABBR_MONTHNAMES.compact.join('|')}';
        ).html_safe
  end

  # Styled only for comunity layout
  def readmore(text, limit = 255)
    if text.size < limit
      simple_format auto_link(text, html: { target: '_blank', ref: 'nofollow' })
    else
      content = auto_link(text[0..limit], html: { target: '_blank', ref: 'nofollow' }) +
                content_tag(:span, content_tag(:span, auto_link(text[limit + 1..-1], html: { target: '_blank', ref: 'nofollow' })), class: 'readmore-a', data: { label: t(:read_more) })
      simple_format content
    end
  end

  def setup_activity_feed_event(event, target = '_self')
    event = ActivityFeedService::Event.new(event, target)
    OpenStruct.new(text: event.text, image: event.image)
  end

  def data_fields_for_schedule
    {
      'add-duration' => I18n.t('schedule.duration'),
      'add-unavailable' => I18n.t('schedule.add_unavailable'),
      'add-availability' => I18n.t('schedule.add_availability'),
      'availability' => I18n.t('schedule.availability'),
      'unavailable' => I18n.t('schedule.unavailable'),
      'start-time' => I18n.t('schedule.start_time'),
      'event' => I18n.t('schedule.event'),
      'specific-dates' => I18n.t('schedule.specific_dates'),
      'every' => I18n.t('schedule.every'),
      'event-before' => I18n.t('schedule.event_before'),
      'this-day-of-week' => I18n.t('schedule.this_day_of_week'),
      'this-hour-of-day' => I18n.t('schedule.this_hour_of_day'),
      'this-minute-of-hour' => I18n.t('schedule.this_minute_of_hour'),
      'this-day-of-nth-week' => I18n.t('schedule.this_day_of_nth_week'),
      'this-nth-day-of-month' => I18n.t('schedule.this_nth_day_of_month'),
      'this-nth-day-of-year' => I18n.t('schedule.this_nth_day_of_year'),
      'pascha-offset' => I18n.t('schedule.pascha_offset'),
      'event-occured-less' => I18n.t('schedule.event_occured_less')
    }
  end

  def html_element_classes
    klasses = []
    klasses << "env-#{Rails.env}"
    klasses << 'no-js'
    klasses << 'signed-in' if current_user
    klasses.join(' ')
  end

  def body_classes
    body_classes = []
    body_classes << 'signed-in' if user_signed_in?
    body_classes.join(' ')
  end

  def current_url
    request.protocol + platform_context.host + request.fullpath
  end

  def is_required?(object, fields)
    object.try(:validation_for, fields).try(:any?, &:is_required?)
  end

  def webpack_bundle_tag(bundle)
    src =
      if Rails.configuration.webpack[:use_manifest]
        manifest = Rails.configuration.webpack[:asset_manifest]
        filename = manifest[bundle]

        "#{compute_asset_host}/assets/#{filename}"
      else
        "#{compute_asset_host}/assets/#{bundle}-bundle.js"
      end

    javascript_include_tag(src, crossorigin: 'anonymous')
  end

  def webpack_manifest_script
    return '' unless Rails.configuration.webpack[:use_manifest]
    javascript_tag "(function(){ window.webpackBundleManifest = #{Rails.configuration.webpack[:common_manifest].to_json}; }());"
  end

  def render_featured_items
    render(partial: @partial_name, collection: @collection, as: :item)
  end

  def dynamic_theme_path_for_current_theme(stylesheet)
    theme = PlatformContext.current.theme

    # It's important that we use _url and not _path as we won't current domain
    # instead of a link using ASSET_HOST / CDN, due to platform context issues
    dynamic_theme_url(theme_id: theme.id, updated_at: theme.updated_at.to_formatted_s(:number), stylesheet: stylesheet)
  end

  def remote_storage_file_name(file_object)
    # We use file_object (most often CarrierWave::Storage::Fog::File) basename(path)
    # first, as filename may not be correct due to the presence of
    # extra slashes in the URL; file_object.path will represent the local path
    # to the file
    File.basename(file_object.path.to_s).presence || file_object.filename
  end

  def parse_with_markdown(text)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(escape_html: true), autolink: true, tables: true, fenced_code_blocks: true)
    markdown.render(text.to_s).html_safe
  end

  def videoify_and_parse_with_markdown(text, embed_options = {})
    embed_options.symbolize_keys!
    markdown = Redcarpet::Markdown.new(HtmlWithVideos.new({ escape_html: true }, embed_options), autolink: true, tables: true, fenced_code_blocks: true)
    markdown.render(text.to_s).html_safe
  end

  def object_updated?(object)
    (object.updated_at - object.created_at) > 1 if object && object.try(:updated_at) && object.try(:created_at)
  end

  def collection_with_new_object(association)
    association.new
    association
  end

  def collection_or_new_object(association)
    association.presence || association.new
  end
end
