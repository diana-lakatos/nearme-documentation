module TooltipHelper

  include FormHelper

  def tooltip(tooltip_text, link_text = "", options = {}, image = "components/form/hint.png")
    options[:rel] = "tooltip"
    options['data-container'] = 'body'
    options[:title] = tooltip_text
    content_tag(:a, ("#{link_text} " + (image.blank? ? '' : image_tag(image))).html_safe, options)
  end

  def tooltip_for_required_field(label_text, tooltip_text)
    required_field tooltip(tooltip_text, label_text)
  end
end
