# frozen_string_literal: true
module Graph
  module Types
    module Search
      Searcher = GraphQL::ObjectType.define do
        name 'Searcher'
        description 'Results for search'

        field :results, !types[Types::Search::LocationResult] do
          resolve ->(obj, _args, _ctx) {
            obj.results.map(&:to_liquid)
          }
        end
        field :lgpricing_filters, !types[types.String]
        field :lgpricing, !types.String
        field :lntype, !types.String
        field :searchable_categories, !types[Types::Search::Category]
        field :filterable_custom_attributes, !types[Types::Search::CustomAttribute] do
          resolve ->(obj, _args, _ctx) {
            obj.filterable_custom_attributes.map do |ca|
              OpenStruct.new(name: ca.name, lg_custom_attribute: obj.lg_custom_attributes[ca.name])
            end
          }
        end
        field :filterable_pricing, !types[types[types.String]] do
          resolve -> (obj, _, _) {
            obj.searcher.filterable_pricing
          }
        end
        field :filterable_location_types, !types[Types::Search::LocationType] do
          resolve -> (obj, _, _) {
            obj.searcher.filterable_location_types
          }
        end
        field :category_ids, !types[types.ID]
        field :location_types_ids, !types[types.ID]

        field :meta_title, !types.String
        field :min_price, !types.Float
        field :max_price, !types.Float
        field :current_min_price, !types.Float
        field :current_max_price, !types.Float
        field :offset, !types.Int

        field :result_count, !types.Int
        field :total_pages, !types.Int
        field :total_entries, !types.Int
        field :per_page, !types.Int
        field :sort, !types.String
        field :current_page, !types.Int
        field :located, types.Boolean
        field :display_dates, !Types::Search::DisplayDates
        field :start_date, types.String
        field :end_date, types.String
        field :keyword, types.String
      end
    end
  end
end
