# frozen_string_literal: true
class AddressForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections
  class << self
    def decorate(configuration = {})
      Class.new(self) do
        configuration.each do |field, options|
          validates :"#{field}", options[:validation] if options[:validation].present?
        end
      end
    end
  end
  property :address
  property :should_check_address, virtual: true

  property :local_geocoding
  property :latitude
  property :longitude
  property :formatted_address

  property :street
  property :suburb
  property :city
  property :state
  property :country
  property :postcode
  property :address_components, field: :hash
end
