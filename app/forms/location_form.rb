# frozen_string_literal: true
class LocationForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections
  class << self
    def decorate(configuration)
      Class.new(self) do
        if (transactables_configuration = configuration.delete(:transactables)).present?
          add_validation(:transactables, transactables_configuration)
          property :transactables, form: TransactablesForm.decorate(transactables_configuration),
                                   from: :transactables_open_struct
        end
        if (location_address_configuration = configuration.delete(:location_address)).present?
          add_validation(:location_address, location_address_configuration)
          property :location_address, form: AddressForm.decorate(location_address_configuration),
                                      populate_if_empty: Address,
                                      prepopulator: ->(*) { self.location_address ||= Address.new }
        end
        inject_dynamic_fields(configuration)
      end
    end
  end
end
