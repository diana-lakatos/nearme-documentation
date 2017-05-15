# frozen_string_literal: true
class CategoriesForm < BaseForm
  class << self
    def decorate(configuration)
      Class.new(self) do
        configuration.each do |field, options|
          inject_dynamic_fields(configuration)

          define_method("#{field}=") do |value|
            super(value.is_a?(Array) ? value.reject(&:blank?) : value)
          end
        end
      end
    end
  end

  def common_categories_json(category)
    send(category.name).map { |c| { id: c.id, name: c.translated_name } }
  end
end
