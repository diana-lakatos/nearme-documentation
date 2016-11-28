# frozen_string_literal: true
class LocationForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections
  class << self
    def decorate(configuration)
      Class.new(self) do
        if (transactables_configuration = configuration.delete(:transactables)).present?
          validation = transactables_configuration.delete(:validation)
          validates :transactables, validation if validation.present?
          property :transactables, form: TransactablesForm.decorate(transactables_configuration),
                                   from: :transactables_open_struct
        end
        if (location_address_configuration = configuration.delete(:location_address)).present?
          property :location_address, form: AddressForm.decorate(location_address_configuration),
                                      populate_if_empty: Address,
                                      prepopulator: ->(*) { self.location_address ||= Address.new }
        end
        configuration.each do |field, options|
          property :"#{field}", options[:property_options].presence || {}
          validates :"#{field}", options[:validation] if options[:validation].present?
        end
      end
    end
  end
end
