# frozen_string_literal: true
class PropertiesForm < BaseForm
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
end
