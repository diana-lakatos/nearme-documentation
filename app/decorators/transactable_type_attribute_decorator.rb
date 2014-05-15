class TransactableTypeAttributeDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  def initialize(*args)
    super(*args)
    @concrete_decorator = case html_tag.to_sym
                          when :input
                            TransactableTypeAttributeDecorator::Input.new(self)
                          when :select
                            TransactableTypeAttributeDecorator::Select.new(self)
                          when :switch
                            TransactableTypeAttributeDecorator::Switch.new(self)
                          when :textarea
                            TransactableTypeAttributeDecorator::TextArea.new(self)
                          when :date
                            TransactableTypeAttributeDecorator::DateAttr.new(self)
                          when :date_time
                            TransactableTypeAttributeDecorator::DateTimeAttr.new(self)
                          when :time
                            TransactableTypeAttributeDecorator::TimeAttr.new(self)
                          when :radio_buttons
                            TransactableTypeAttributeDecorator::RadioButton.new(self)
                          when :check_box
                            TransactableTypeAttributeDecorator::CheckBox.new(self)
                          when :check_box_list
                            TransactableTypeAttributeDecorator::CheckBoxList.new(self)
                          else
                            raise NotImplementedError.new("Not implemented options for #{html_tag}")
                          end
  end

  def options
    @options ||= default_options.deep_merge(@concrete_decorator.options)
  end

  def default_options
    @default_options ||= {
      input_html: input_html_options,
      required: required?
    }
  end

  def valid_values_translated
    valid_values.map do |valid_value|
      [I18n.translate('simple_form.valid_values.transactable.' + self.name + '.' + valid_value.underscore.tr(' ', '_')), valid_value]
    end
  end

  private

  def required?
    @required ||= validation_rules.present? && !validation_rules["presence"].nil?
  end

end
