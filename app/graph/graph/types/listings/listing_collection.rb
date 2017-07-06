# frozen_string_literal: true
module Graph
  module Types
    module Listings
      ListingCollection = GraphQL::ObjectType.define do
        name 'ListingCollection'

        field :total_entries, !types.Int
        field :total_pages, !types.Int

        field :results, types[Graph::Types::Listings::Listing]
      end

      Listing = GraphQL::ObjectType.define do
        name 'Listing'

        global_id_field :id

        field :id, !types.ID
        field :created_at, types.String
        field :updated_at, types.String

        field :name, !types.String
        field :slug, !types.String

        field :currency, !types.String
        field :description, types.String
        field :summary, types.String

        field :address, Graph::Types::Address

        field :type, types.String do
          resolve ->(obj, _arg, _ctx) { obj.transactable_type.name }
        end
        field :all_prices, types[types.Int]

        field :category_list, types[Graph::Types::Category] do
          argument :name_of_root, types.String

          resolve ->(obj, arg, _ctx) {
            obj
              .category_list
              .select { |c| arg[:name_of_root].blank? || c.name_of_root == arg[:name_of_root] }
              .sort { |a, b| a.permalink <=> b.permalink }
          }
        end

        field :photos, types[Graph::Types::EsImage]

        field :custom_attribute,
              types.String,
              'Fetch any custom attribute by name, ex: hair_color: custom_attribute(name: "hair_color")' do
          argument :name, !types.String
          resolve ->(obj, arg, _ctx) { obj.custom_attributes[arg[:name]] }
        end

        field :creator, Graph::Types::User
      end
    end
  end
end
