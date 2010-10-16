module ApplicationHelper
  
  def title(page_title, show_title = true)
    content_for(:title) { h(page_title.to_s) }
    @show_title = show_title
  end
  
  def show_title?
    @show_title
  end

  def flashes
    # :notice, :error and :message are used by omnisocia, but your only
    # suppsed to use alter and notice.
    buffer = ""
    [ :alert, :notice, :message, :error ].each do |f|
      buffer << content_tag(:div, flash[f], :id => f, :class => "flash") if flash.key?(f)
    end
    buffer.html_safe
  end
  
end
