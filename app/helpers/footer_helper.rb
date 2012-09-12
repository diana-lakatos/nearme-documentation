module FooterHelper

  def footer_link(caption, url, active_value = nil, options = {})
    active_value ||= caption.downcase.parameterize("_").to_sym
    active       = "active" if @footer_tab == active_value
    content_tag(:li, link_to(caption, url), class: "#{options[:class]} #{active}")
  end

end