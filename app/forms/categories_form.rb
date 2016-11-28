# frozen_string_literal: true
class CategoriesForm < BaseForm
  class << self
    def decorate(configuration)
      Class.new(self) do
        configuration.each do |field, options|
          property :"#{field}"
          validates :"#{field}", options[:validation] if options[:validation].present?
        end
      end
    end
  end

  def common_categories_json(category)
    send(category.name).map { |c| { id: c.id, name: c.translated_name } }
  end
end
