module CustomAttributes
  module CustomAttributesHelper
    def draw_attribute_for_form(attribute, form, with_private = false, extra_options = {})
      return nil unless (attribute.public || with_private) && attribute.html_tag.present?
      form_element = ::CustomAttributes::CustomAttribute::FormElementDecorator.new(attribute)
      case attribute.html_tag.to_sym
      when :input, :select, :textarea, :radio_buttons, :date, :date_time, :time
        render partial: 'custom_attributes/input', locals: { attribute: form_element, f: form, extra_options: extra_options }
      when :check_box
        render partial: 'custom_attributes/check_box', locals: { attribute: form_element, f: form }
      when :check_box_list
        render partial: 'custom_attributes/check_box_list', locals: { attribute: form_element, f: form, extra_options: extra_options }
      when :switch
        render partial: 'custom_attributes/switch', locals: { attribute: form_element, f: form }
      when :range
        render partial: 'custom_attributes/range', locals: { attribute: form_element, f: form }
      when :hidden
        render partial: 'custom_attributes/hidden', locals: { attribute: form_element, f: form }
      else
        raise "Unknown: #{attribute.html_tag}"
      end
    end
  end
end
