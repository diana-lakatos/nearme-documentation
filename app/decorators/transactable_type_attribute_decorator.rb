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
                          else
                            raise NotImplementedError.new("Not implemented options for #{html_tag}")
                          end
  end

  def options
    @options ||= default_options.deep_merge(@concrete_decorator.options)
  end

  def default_options
    @default_options ||= {
      label: label,
      hint: hint,
      input_html: input_html_options,
      required: required?
    }
  end

  private

  def required?
    @required ||= validation_rules.present? && !validation_rules["presence"].nil?
  end

end
