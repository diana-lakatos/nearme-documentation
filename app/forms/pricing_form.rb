# frozen_string_literal: true
class PricingForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections
  property :transactable_type_pricing_id
  property :enabled
  class << self
    def decorate(configuration)
      Class.new(self) do
        configuration.each do |field, options|
          property :"#{field}", options[:property_options].presence || {}
          validates :"#{field}", options[:validation] if options[:validation].present?
        end
      end
    end
  end
end
