# frozen_string_literal: true
class CompanyForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections
  class << self
    def decorate(configuration)
      Class.new(self) do
        if (locations_configuration = configuration.delete(:locations)).present?
          validation = locations_configuration.delete(:validation)
          validates :locations, validation if validation.present?
          collection :locations, form: LocationForm.decorate(locations_configuration),
                                 populate_if_empty: Location,
                                 prepopulator: ->(*) { locations << Location.new if locations.size.zero? }
        end
        configuration.each do |field, options|
          property :"#{field}", options[:property_options].presence || {}
          validates :"#{field}", options[:validation] if options[:validation].present?
        end
      end
    end
  end
end
