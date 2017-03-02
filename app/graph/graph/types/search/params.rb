# frozen_string_literal: true
module Graph
  module Types
    module Search
      Params = GraphQL::InputObjectType.define do
        name('SearchParams')
        argument :query, types.String, 'Search by name, tags, description'
        argument :loc, types.String
        argument :lat, types.String
        argument :lng, types.String
        argument :nx, types.String
        argument :ny, types.String
        argument :sx, types.String
        argument :sy, types.String
        argument :country, types.String
        argument :state, types.String
        argument :city, types.String
        argument :name, types.String
        argument :postcode, types.String
        argument :suburb, types.String
        argument :street, types.String
        argument :language, types.String
        argument :page, types.Int
        argument :per_page, types.Int
        argument :sort, types.String
      end
    end
  end
end
