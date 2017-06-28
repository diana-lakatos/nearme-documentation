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
        inject_dynamic_fields(configuration, whitelisted: [:name, :email, :description, :url, :paypal_email, :white_label_enabled, :listings_public])
      end
    end
  end

  # @!attribute name
  #   @return [String] name for the company
  # @!attribute email
  #   @return [String] email for the company
  # @!attribute description
  #   @return [String] description for the company
  # @!attribute url
  #   @return [String] URL address of the company's website
  # @!attribute paypal_email
  #   @return [String] PayPal email address for the company
  # @!attribute white_label_enabled
  #   @return [Boolean] whether the company functions as a white label for another entity
  #     white label companies can also have their own domain
  # @!attribute listings_public
  #   @return [Boolean] for white label companies if this is false the listings will
  #     only be visible on their own domains

  # @!attribute locations
  #   @return [Array<LocationForm>] locations for the company
end
