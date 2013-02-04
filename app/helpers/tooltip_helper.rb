module TooltipHelper

  include FormHelper

  def tooltip(tooltip_text, link_text = "", options = {})
    options[:rel] = "tooltip"
    options[:title] = tooltip_text
    content_tag(:a, ("#{link_text} " + image_tag("components/form/hint.png")).html_safe, options)
  end

  def tooltip_for_required_field(label_text, tooltip_text)
    required_field tooltip(tooltip_text, label_text)
  end
end
