# frozen_string_literal: true
module Graph
  module Types
    module Search
      LocationResult = GraphQL::ObjectType.define do
        name 'LocationResult'
        description 'Location result for search'

        global_id_field :id

        field :id, !types.Int
        field :name, !types.String
        field :latitude, !types.String
        field :longitude, !types.String
        field :street, !types.String
        field :photos, !types[Types::Search::Photo] do
          resolve ->(obj, _args, _ctx) {
            obj.photos.map { |p| Hashie::Mash.new(p)}
          }
        end
        field :company, !Graph::Types::Company
        field :listings, !types[Graph::Types::Transactables::Transactable] do
          resolve ->(obj, _args, _ctx) { obj.listings.map(&:to_liquid) }
        end
        field :path, !types.String
      end
    end
  end
end
