module ApplicationHelper

  include FormHelper
  include TooltipHelper
  include CurrencyHelper
  include FileuploadHelper
  include SharingHelper

  def platform_context
    @platform_context_view ||= @platform_context.decorate
  end

  def title(page_title, show_title = true)
    content_for(:title) { h(page_title.to_s) }
    @show_title = show_title
  end

  def meta_title(name)
    content_for(:meta_title) { h(name.to_s) }
  end

  def title_tag
    (show_title? ? content_for(:title) : platform_context.tagline.to_s) +
      (additional_meta_title.presence ? " | " + additional_meta_title : '')
  end

  def meta_description(description)
    content_for(:meta_description) { h(description.to_s) }
  end

  def meta_description_content
    content_for?(:meta_description) ? content_for(:meta_description) : (platform_context.description || platform_context.name)
  end

  def additional_meta_title
    content_for?(:meta_title) ? content_for(:meta_title) : platform_context.meta_title
  end

  def legacy(is_legacy = true)
    @is_legacy = is_legacy
  end

  def legacy?
    !defined?(@is_legacy) || @is_legacy
  end

  def show_title?
    @show_title
  end

  def apply_analytics?
    # Enable mixpanel in all environments. We use a different account for
    # production.
    true
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

      excess_body = (body.split - truncated_body)

      content_tag(:p, html_options) do
        truncated_body.join(" ").html_safe +
        content_tag(:span, "&hellip;".html_safe, :class => 'truncated-ellipsis').html_safe +
        content_tag(:span, excess_body.join(" ").html_safe, :class => 'truncated-text hidden').html_safe
      end

    else
      body
    end

  end

  def get_return_to_url
    in_signed_in_or_sign_up? ? {} : {:return_to => "#{request.protocol}#{request.host_with_port}#{request.fullpath}"}
  end

  def in_signed_in_or_sign_up?
    in_signed_in? || in_sign_up?
  end

  def in_signed_in?
    params[:controller]=='sessions'
  end

  def in_sign_up?
    params[:controller]=='registrations'
  end

  def link_to_once(*args, &block)
    options = args.first || {}
    html_options = args.second || {}

    unless html_options.key?(:disable_with) then html_options[:disable_with] = "Loading..." end
    if block_given?
      link_to(capture(&block), options, html_options)
    else
      link_to(options, html_options)
    end
  end

  def ico_for_flash(key)
    case key.to_s
    when 'notice' 
      "ico-check"
    when 'success'
      "ico-check"
    when 'error' 
      "ico-warning"
    when 'warning'
      "ico-warning"
    when 'deleted'
      "ico-close"
    end
  end

  def show_manage_navigation(active_tab = :locations)
    content_for :manage_navbar, render(:partial => 'shared/manage_navigation', :locals => {:active_tab => active_tab})
  end

  def section_class(section_name = nil)
    [
      section_name, 
      controller_name, 
      "#{controller_name}-#{params[:action]}"
    ].compact.join(' ')
  end

  def dnm_page_class
    [
      content_for?(:manage_navbar) ? 'with-sub-navbar' : nil,
      no_navbar? ? 'no-navbar' : nil
    ].compact.join(' ')
  end

  def distance_of_time_in_words_or_date(datetime)
    today = Date.current

    if datetime.to_date == today
      datetime.strftime("%l:%M%P")
    elsif datetime.to_date == today.yesterday
      'Yesterday'
    elsif datetime > (today - 7.days)
      datetime.strftime("%A")
    else
      datetime.strftime("%Y-%m-%d")
    end
  end

  def distance_of_time_in_words_or_date_in_time_zone(datetime, time_zone = 'UTC')
    Time.zone = time_zone
    result = distance_of_time_in_words_or_date(datetime.in_time_zone(time_zone))
    Time.zone = 'UTC'
    result
  end

  def render_olark?
    not params[:controller] == 'locations' && params[:action] == 'show'
  end

  def nl2br(str)
    str.to_s.gsub(/\r\n|\r|\n/, "<br />").html_safe
  end

end
