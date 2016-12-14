module CustomAttributes
  class CustomAttribute::FormElementDecorator
    delegate :name, :label, :errors, :valid_values, :input_html_options, :wrapper_html_options, :html_tag,
             :label_key, :attribute_type, :prompt_key, :placeholder_key, :hint_key, :required?, to: :attribute

    attr_accessor :attribute

    def initialize(attribute)
      self.attribute = attribute
      @concrete_form_element = case html_tag.to_sym
                               when :input
                                 CustomAttribute::FormElementDecorator::Input.new(attribute)
                               when :select
                                 CustomAttribute::FormElementDecorator::Select.new(attribute)
                               when :switch
                                 CustomAttribute::FormElementDecorator::Switch.new(attribute)
                               when :textarea
                                 CustomAttribute::FormElementDecorator::TextArea.new(attribute)
                               when :date
                                 CustomAttribute::FormElementDecorator::DateAttr.new(attribute)
                               when :date_time
                                 CustomAttribute::FormElementDecorator::DateTimeAttr.new(attribute)
                               when :time
                                 CustomAttribute::FormElementDecorator::TimeAttr.new(attribute)
                               when :radio_buttons
                                 CustomAttribute::FormElementDecorator::RadioButton.new(attribute)
                               when :check_box
                                 CustomAttribute::FormElementDecorator::CheckBox.new(attribute)
                               when :check_box_list
                                 CustomAttribute::FormElementDecorator::CheckBoxList.new(attribute)
                               when :range
                                 CustomAttribute::FormElementDecorator::RangeAttr.new(attribute)
                               when :hidden
                                 CustomAttribute::FormElementDecorator::HiddenAttr.new(attribute)
                               else
                                 raise NotImplementedError, "Not implemented options for #{html_tag}"
                               end
    end

    def options
      @options ||= default_options.deep_merge(@concrete_form_element.options)
    end

    def default_options
      @default_options ||= {
        wrapper_html: wrapper_html_options,
        input_html: input_html_options,
        label: I18n.translate(attribute.label_key, default: attribute.name.try(:humanize)),
        hint: I18n.translate(attribute.hint_key, default: '').presence || nil,
        placeholder: I18n.translate(attribute.placeholder_key, default: '').presence || nil,
        include_blank: I18n.translate(attribute.prompt_key, default: '').presence || nil,
        required: required?
      }
    end
  end
end
