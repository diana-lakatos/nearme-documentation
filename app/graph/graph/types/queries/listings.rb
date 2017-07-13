# frozen_string_literal: true
module Graph
  module Types
    module Queries
      Listings = GraphQL::ObjectType.define do
        field :listings, Graph::Types::Listings.collection(Graph::Types::Listings::Listing) do
          argument :query, types.String, 'Fulltext search'
          argument :sort, types[Graph::Types::Queries::SortOrder]
          argument :page, types.Int, default_value: 1
          argument :per_page, types.Int, default_value: 20
          argument :listing, Graph::Types::Queries::Listing

          resolve Graph::Resolvers::Elastic::Listings.new
        end

        field :people, Graph::Types::Listings.collection(Graph::Types::Listings::User) do
          argument :query, types.String, 'Fulltext search'
          argument :sort, types[Graph::Types::Queries::SortOrder]
          argument :page, types.Int, default_value: 1
          argument :per_page, types.Int, default_value: 20
          argument :user, Graph::Types::Queries::User

          resolve Graph::Resolvers::Elastic::People.new
        end
      end

      User = GraphQL::InputObjectType.define do
        name 'QueryUser'

        argument :is_deleted, types.Boolean
        argument :address, Graph::Types::Queries::ListingLocation, as: :current_address
        argument :name, types.String
        argument :tags, types[types.String]

        argument :profiles, types[Graph::Types::Queries::Profile]
      end

      Profile = GraphQL::InputObjectType.define do
        name 'QueryUserProfile'

        argument :location, Graph::Types::Queries::ListingLocation
        argument :address, Graph::Types::Queries::ListingLocation
        argument :is_deleted, types.Boolean
        argument :enabled, types.Boolean
        argument :custom_attributes, types[Graph::Types::Queries::CustomAttribute]
        argument :properties, types[Graph::Types::Queries::CustomAttribute]

        argument :profile_types, types[types.String]
        argument :profile_type, types.String
        argument :categories, types[Graph::Types::Queries::Category]
        argument :category_ids, Graph::Types::Queries::List

        argument :name, types.String
      end

      Listing = GraphQL::InputObjectType.define do
        name 'QueryListing'

        argument :has_creator, types.Boolean

        argument :location, Graph::Types::Queries::ListingLocation
        argument :address, Graph::Types::Queries::ListingLocation
        argument :is_deleted, types.Boolean
        argument :custom_attributes, types[Graph::Types::Queries::CustomAttribute]
        argument :properties, types[Graph::Types::Queries::CustomAttribute]

        argument :transactable_types, types[Graph::Types::Queries::TransactableType]
        argument :categories, types[Graph::Types::Queries::Category]
        argument :category_ids, Graph::Types::Queries::List
        argument :customizations, types[Graph::Types::Queries::Customization]

        argument :name, types.String
        argument :state, types.String
        argument :slug, types.String
        argument :creator_id, types.ID
      end

      SortOrder = GraphQL::InputObjectType.define do
        name 'SortOrder'

        argument :key, types.String
        argument :profile_key, types.String
        argument :profile_type, types.String

        argument :order, types.String, default_value: 'asc'
      end

      TransactableType = GraphQL::InputObjectType.define do
        name 'QueryTransactableType'

        argument :id, types.Int
        argument :name, types.String
      end

      Category = GraphQL::InputObjectType.define do
        name 'QueryCategory'

        argument :id, types.Int
        argument :ids, types[types.Int]
        argument :name_of_root, types.String
        argument :value, types.String
        argument :values, types[types.String]
      end

      Customization = GraphQL::InputObjectType.define do
        name 'QueryCustomization'

        argument :id, types.ID
        argument :name, types.String
        argument :parameterized_name, types.String
        argument :user_id, types.ID
      end

      CustomAttribute = GraphQL::InputObjectType.define do
        name 'QueryCustomAttribute'

        argument :name, !types.String
        argument :value, types.String
        argument :values, types[types.String]
      end

      List = GraphQL::InputObjectType.define do
        name 'QueryOptionList'

        argument :options, !types[types.String]
        argument :operand, types.String, default_value: 'AND'
      end

      BoundingBox = GraphQL::InputObjectType.define do
        name 'QueryBoundingBoxCoordinates'
        argument :nx, !types.String
        argument :ny, !types.String
        argument :sx, !types.String
        argument :sy, !types.String
      end

      Coordinates = GraphQL::InputObjectType.define do
        name 'QueryPointCoordinates'
        argument :lat, !types.String
        argument :lng, !types.String
      end

      ListingLocation = GraphQL::InputObjectType.define do
        name 'QueryListingLocation'

        argument :coords, Graph::Types::Queries::Coordinates
        argument :bounding_box, Graph::Types::Queries::BoundingBox

        argument :street, types.String
        argument :suburb, types.String
        argument :postcode, types.String
        argument :city, types.String
        argument :state, types.String
        argument :country, types.String
      end
    end
  end
end
