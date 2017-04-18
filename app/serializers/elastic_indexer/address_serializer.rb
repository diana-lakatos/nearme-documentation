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
               :street_number
  end
end
