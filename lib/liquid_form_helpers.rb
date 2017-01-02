module LiquidFormHelpers
  # http://api.rubyonrails.org/classes/ActionView/Helpers/FormOptionsHelper.html#method-i-options_for_select
  def options_for_select(*args)
    form_helper.options_for_select(*args)
  end

  def options_from_collection_for_select(collection, selected = nil, include_blank = false)
    return [] unless collection

    collection = unshift_blank(collection, selected, include_blank) if include_blank

    collection.map do |item|
      label = item.label
      is_selected = Array(selected).include?(item.key)
      title = item.value.zero? && '' || item.value
      css_class = 'filter-results-present' unless title.blank?

      content_tag :option, label, selected: is_selected, value: item.key, class: css_class, title: title
    end
  end

  private

  def unshift_blank(collection, selected, label, default_label = 'Please select')
    label = selected.present? ? label : default_label
    collection.unshift first_select_option(label)
  end

  def first_select_option(label)
    OpenStruct.new(label: label, key: '', value: 0, disabled: false)
  end

  class RailsFormHelpersProxy
    include ActionView::Helpers::FormOptionsHelper
  end

  def form_helper
    RailsFormHelpersProxy.new
  end
end
