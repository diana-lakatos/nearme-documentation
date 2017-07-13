# frozen_string_literal: true
module Graph
  module Types
    module Listings
      def self.collection(type)
        collections[type] ||= build_type(type)
      end

      def self.collections
        ::Thread.current[:graph_collections] ||= {}
      end

      def self.build_type(type)
        GraphQL::ObjectType.define do
          name "#{type.name}Collection"

          field :total_entries, !types.Int
          field :total_pages, !types.Int
          field :size, !types.Int

          field :has_next_page, !types.Boolean do
            resolve ->(obj, _args, _ctx) { obj.page < obj.total_pages }
          end

          field :has_previous_page, !types.Boolean do
            resolve ->(obj, _args, _ctx) { obj.page > 1 }
          end

          field :results, types[type]
        end
      end

      User = GraphQL::ObjectType.define do
        name 'UserListing'

        field :id, !types.ID
        field :created_at, types.String
        field :updated_at, types.String

        field :name, !types.String
        field :slug, !types.String

        field :tag_list, types[Graph::Types::Tag]

        field :photos, types[Graph::Types::EsImage]
        field :current_address, Types::Address # , deprecation_reason: 'Use custom-address'
        field :blog, Graph::Types::Blog

        field :profile, Types::Users::Profile do
          argument :profile_type, !types.String
          resolve ->(obj, args, _ctx) { obj.user_profiles.find { |up| up.profile_type == args[:profile_type] } }
        end
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
        field :state, types.String

        field :address, Graph::Types::Address

        field :type, types.String do
          resolve ->(obj, _arg, _ctx) { obj.transactable_type.name }
        end
        field :all_prices, types[types.Int]

        field :category_list, types[Graph::Types::Category] do
          argument :name_of_root, types.String

          resolve lambda { |obj, arg, _ctx|
            obj
              .category_list
              .select { |c| arg[:name_of_root].blank? || c.name_of_root == arg[:name_of_root] }
              .sort_by(&:permalink)
          }
        end

        field :customizations, types[Graph::Types::Customizations::Customization] do
          argument :name, types.String
          resolve lambda { |obj, args, _ctx|
            return obj.customizations if args[:name].blank?
            obj.customizations.select { |c| c.name == args[:name] }
          }
        end

        field :photos, types[Graph::Types::EsImage]

        field :property_array, types[types.String] do
          argument :name, !types.String
          resolve ->(obj, args, _ctx) { obj.properties[args[:name]] }
        end

        field :property,
              types.String,
              'Fetch any custom attribute by name, ex: hair_color: property(name: "hair_color")' do
          argument :name, !types.String
          resolve ->(obj, arg, _ctx) { obj.properties[arg[:name]] }
        end

        field :creator, Graph::Types::User
      end
    end
  end
end
