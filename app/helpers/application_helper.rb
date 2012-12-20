module ApplicationHelper

  include TweetButton
  
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
  
  def our_twitter_accounts
    buffer = []
    {
      "Keith Pitt" => "keithpitt",
      "Warren Seen" => "warren_s",
      "Bo Jeanes" => "bjeanes",
      "Alex Eckermann" => "alexeckermann"
    }.each do |k,v|
      buffer << link_to(k, "http://twitter.com/#{v}")
    end
    buffer.join(', ').html_safe
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
      
      content_tag(:div, html_options) do
        truncated_body.join(" ").html_safe +
        content_tag(:span, "&hellip;".html_safe, :class => 'truncated-ellipsis').html_safe +
        content_tag(:span, excess_body.join(" ").html_safe, :class => 'truncated-text hidden').html_safe
      end

    else
      body
    end

  end

end
