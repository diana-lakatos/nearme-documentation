# frozen_string_literal: true
module ElasticIndexer
  class AddressSerializer < BaseSerializer
    attributes :address,
               :address2,
               :formatted_address,
               :street,
               :suburb,
               :city,
               :country,
               :state,
               :postcode,
               :iso_country_code,
               :street_number,
               :lat,
               :lon

    def lat
      object.latitude
    end

    def lon
      object.longitude
    end
  end
end
