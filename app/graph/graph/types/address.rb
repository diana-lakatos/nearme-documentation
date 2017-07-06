# frozen_string_literal: true
module Graph
  module Types
    Address = GraphQL::ObjectType.define do
      name 'Address'
      description 'An address'

      global_id_field :id

      field :id, !types.Int
      field :address, types.String
      field :city, types.String
      field :iso_country_code, types.String
      field :latitude, types.Float
      field :longitude, types.Float
      field :postcode, types.String
      field :suburb, types.String
      field :state, types.String
      field :street, types.String
      field :street_number, types.String
      field :country, types.String
    end
  end
end
