# frozen_string_literal: true
module Graph
  module Resolvers
    module Elastic
      class ListingResolver < BaseResolver
        private

        def resolve
          resolve_argument :has_creator do |args|
            Graph::Resolvers::Elastic::ListingCreatorResolver.new.call(self, args, ctx)
          end

          resolve_argument :is_deleted do |value|
            BooleanFieldResolver.new.call(self, { deleted_at: value }, ctx)
          end

          resolve_argument :location do |value|
            ListingLocationResolver.new.call(self, value, ctx)
          end

          resolve_argument :address do |value|
            ListingAddressResolver.new(field_name: 'address').call(self, value, ctx)
          end

          resolve_argument :current_address do |value|
            ListingAddressResolver.new(field_name: 'current_address').call(self, value, ctx)
          end

          resolve_argument :properties do |value|
            PropertyGroupResolver.new.call(self, value, ctx)
          end

          resolve_argument :categories do |value|
            CategoryGroupResolver.new.call(self, value, ctx)
          end

          resolve_argument :profiles do |value|
            UserProfileGroupResolver.new.call(self, value, ctx)
          end

          resolve_argument :customizations do |value|
            CustomizationGroupResolver.new.call(self, value, ctx)
          end

          resolve_argument :slug do |value|
            term_argument('slug' => value)
          end

          resolve_argument :creator_id do |value|
            term_argument('creator_id' => value.to_i)
          end

          resolve_argument :state do |value|
            term_argument('state' => value)
          end

          resolve_argument :creator_id do |value|
            {
              filter: {
                bool: {
                  must: [{ term: { 'creator_id' => value.to_i } }]
                }
              }
            }
          end

          resolve_argument :tags do |values|
            {
              filter: {
                bool: {
                  should: [
                    { terms: { 'tag_list.slug' => values } },
                    { terms: { 'tag_list.name' => values } }
                  ]
                }
              }
            }
          end
        end

        def term_argument(value)
          {
            filter: {
              bool: {
                must: [{ term: value }]
              }
            }
          }
        end

        # FIXME: rethink and refactor
        class BooleanFieldResolver < BaseResolver
          def resolve
            resolve_argument :deleted_at do |value|
              resolve_key :deleted_at, value
            end
          end

          private

          def resolve_key(field, value)
            value ? exists(field) : missing(field)
          end

          def exists(field)
            base(:exists, field)
          end

          def missing(field)
            base(:missing, field)
          end

          def base(key, field)
            {
              filter: {
                bool: {
                  must: [
                    { key => { field: field } }
                  ]
                }
              }
            }
          end
        end
      end
    end
  end
end
