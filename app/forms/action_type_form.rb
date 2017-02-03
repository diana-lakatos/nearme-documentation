# frozen_string_literal: true
class ActionTypeForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections
  property :transactable_type_action_type_id
  property :type
  property :enabled
  class << self
    def decorate(configuration)
      Class.new(self) do
        if (pricings_configuration = configuration.delete(:pricings)).present?
          validation = pricings_configuration.delete(:validation)
          validates :pricings, validation if validation.present?
          collection :pricings, form: PricingForm.decorate(pricings_configuration),
                                populate_if_empty: Transactable::Pricing
        end
        configuration.each do |field, options|
          property :"#{field}", options[:property_options].presence || {}
          validates :"#{field}", options[:validation] if options[:validation].present?
        end
      end
    end
  end
end
