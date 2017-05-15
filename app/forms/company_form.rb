# frozen_string_literal: true
class CompanyForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections
  class << self
    def decorate(configuration)
      Class.new(self) do
        if (locations_configuration = configuration.delete(:locations)).present?
          add_validation(:locations, locations_configuration)
          collection :locations, form: LocationForm.decorate(locations_configuration),
                                 populate_if_empty: Location,
                                 prepopulator: ->(*) { locations << Location.new if locations.size.zero? }
        end
        inject_dynamic_fields(configuration)
      end
    end
  end
end
