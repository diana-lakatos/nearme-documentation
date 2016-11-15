# frozen_string_literal: true
# just proof of concept
# it's not implemented/integrated anywhere
module SendleApi
  module Validations
    def self.sender(contact:, address:, instructions:)
      {
        contact: Validations.contact(contact),
        address: Validations.address(address),
        instructions: instructions
      }
    end

    def self.address(address_line1:, suburb:, state_name:, postcode:, country:)
      {
        address_line1: address_line1,
        suburb: suburb,
        state_name: state_name,
        postcode: postcode,
        country: country
      }
    end

    def self.contact(name:, email:)
      {
        name: name,
        email: email
      }
    end

    ORDER_FIELDS = [:pickup_date, :description, :kilogram_weight,
                    :cubic_metre_volume, :customer_reference, :metadata,
                    :sender, :receiver].freeze

    # FIXME: validate nested
    def self.order(**args)
      missing = ORDER_FIELDS & args.keys

      raise_error(missing) if missing.any?

      args
    end

    def self.raise_error(list)
      raise ArgumentError, "Missing keys: #{list.join(', ')}"
    end
  end
end
