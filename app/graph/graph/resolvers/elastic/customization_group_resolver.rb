# frozen_string_literal: true
module Graph
  module Resolvers
    module Elastic
      class CustomizationGroupResolver < BaseResolver
        private

        def resolve
          resolve_each_argument do |argument|
            CustomizationResolver.new.call(self, argument, ctx)
          end
        end
      end

      class CustomizationResolver < BaseResolver
        private

        def resolve
          resolve_argument :name do |value|
            base(term: { 'customizations.name' => value })
          end

          resolve_argument :human_name do |value|
            base(match: { 'customizations.human_name' => value })
          end

          resolve_argument :user_id do |value|
            base(term: { 'customizations.user_id' => value })
          end

          resolve_argument :id do |value|
            base(term: { 'customizations.id' => value })
          end
        end

        def base(term)
          {
            filter: {
              bool: {
                must: [
                  {
                    nested: {
                      path: 'customizations',
                      filter: {
                        bool: {
                          must: [term]
                        }
                      }
                    }
                  }
                ]
              }
            }
          }
        end
      end
    end
  end
end
