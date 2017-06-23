# frozen_string_literal: true
class AddressForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections
  class << self
    def decorate(configuration = {})
      Class.new(self) do
        configuration.each do |field, options|
          add_validation(field, options)
        end
      end
    end
  end

  # @!attribute address
  #   @return [String] formatted full address for the address object
  property :address

  # @!attribute should_check_address
  #   @return [Boolean] virtual property; whether the system should
  #     check for the presence of an accurate address including
  #     postcode, city, state, street 
  property :should_check_address, virtual: true

  property :local_geocoding

  # @!attribute latitude
  #   @return [Float] latitude for the address object
  property :latitude

  # @!attribute longitude
  #   @return [Float] longitude for the address object
  property :longitude

  # @!attribute formatted_address
  #   @return [String] formatted full address for the address object
  property :formatted_address

  # @!attribute street
  #   @return [String] street name for the address object
  property :street

  # @!attribute suburb
  #   @return [String] suburb name for the address object
  property :suburb

  # @!attribute city
  #   @return [String] city name for the address object
  property :city

  # @!attribute state
  #   @return [String] state name for the address object
  property :state

  # @!attribute country
  #   @return [String] country name for the address object
  property :country

  # @!attribute postcode
  #   @return [String] postcode for the address object
  property :postcode

  # @!attribute address_components
  #   @return [Array<Hash<String => String>>] array of components for the address
  #     keys are mostly long_name (e.g. California), short name (e.g. CA)
  #     and types (e.g. administrative_area_level_1,political)
  collection :address_components
end
