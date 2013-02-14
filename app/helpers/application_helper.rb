module ApplicationHelper

  include FormHelper
  include TooltipHelper
  include TweetButton
  include CurrencyHelper

  def title(page_title, show_title = true)
    content_for(:title) { h(page_title.to_s) }
    @show_title = show_title
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
    Rails.env.production?
  end

  def stripe_public_key
    DesksnearMe::Application.config.stripe_public_key
  end

  def flashes
    # :notice, :error and :message are used by omnisocia, but your only
    # suppsed to use alter and notice.
    buffer = ""
    [ :alert, :notice, :message, :error ].each do |f|
      buffer << content_tag(:div, flash[f], :class => "flash #{f}") if flash.key?(f)
    end
    buffer.html_safe
  end

  def context_flash
    render 'shared/context_flash'
  end

  def truncate_with_ellipsis(body, length, html_options = {})

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
    params[:controller]=='session' ? {} : {:return_to => "#{request.protocol}#{request.host_with_port}#{request.fullpath}"}
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
end
