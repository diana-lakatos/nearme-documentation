# frozen_string_literal: true
module Graph
  module Resolvers
    module Elastic
      class ListingResolver < BaseResolver
        private

        def resolve
          resolve_argument :is_deleted do |value|
            BooleanFieldResolver.new.call(self, { deleted_at: value }, ctx)
          end

          resolve_argument :location do |value|
            ListingLocationResolver.new.call(self, value, ctx)
          end

          resolve_argument :address do |value|
            ListingAddressResolver.new.call(self, value, ctx)
          end

          resolve_argument :custom_attributes do |value|
            CustomAttributeGroupResolver.new.call(self, value, ctx)
          end

          resolve_argument :categories do |value|
            CategoryGroupResolver.new.call(self, value, ctx)
          end
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
