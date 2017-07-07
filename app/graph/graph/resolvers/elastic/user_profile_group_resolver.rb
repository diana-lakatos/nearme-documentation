# frozen_string_literal: true
module Graph
  module Resolvers
    module Elastic
      class UserProfileGroupResolver < BaseResolver
        private

        def resolve
          resolve_each_argument do |value|
            UserProfileResolver.new.call(self, value, ctx)
          end
        end
      end

      class UserProfileResolver < BaseResolver
        private

        def resolve
          resolve_argument :profile_type do |value|
            {
              nested: {
                path: 'user_profiles',
                filter: {
                  bool: {
                    must: [{ term: { 'user_profiles.profile_type' => value } }]
                  }
                }
              }
            }
          end

          resolve_argument :enabled do |value|
            {
              nested: {
                path: 'user_profiles',
                filter: {
                  bool: {
                    must: [{ term: { 'user_profiles.enabled' => value } }]
                  }
                }
              }
            }
          end

          resolve_argument :categories do |value|
            ProfileCategoryGroupResolver.new.call(self, value, ctx)
          end

          resolve_argument :properties do |value|
            ProfilePropertyGroupResolver.new.call(self, value, ctx)
          end
        end

        # FIXME: name
        def prepare
          { filter: { bool: { must: [builder.to_hash] } } }
        end
      end

      class ProfilePropertyGroupResolver < BaseResolver
        private

        def resolve
          resolve_each_argument do |argument|
            ProfilePropertyResolver.new.call(self, argument, ctx)
          end
        end
      end

      # TODO: compare to PropertyGroupResolver and PropertyResolver
      # and extract abstraction
      class ProfilePropertyResolver < BaseResolver
        private

        def resolve
          resolve_argument :value do |value, node|
            {
              nested: {
                path: 'user_profiles',
                filter: {
                  bool: { must: [{ term: { property_field_name(node[:name]) => value } }] }
                }
              }
            }
          end

          resolve_argument :values do |value, node|
            {
              nested: {
                path: 'user_profiles',
                filter: {
                  bool: { must: [{ terms: { property_field_name(node[:name]) => value } }] }
                }
              }
            }
          end
        end

        def property_field_name(name)
          "user_profiles.properties.#{name}.raw"
        end
      end

      class ProfileCategoryGroupResolver < BaseResolver
        private

        def resolve
          resolve_each_argument do |argument|
            ProfileCategoryResolver.new.call(self, argument, ctx)
          end
        end
      end

      class ProfileCategoryResolver < BaseResolver
        private

        def resolve
          resolve_argument :ids do |values|
            {
              nested: {
                path: 'user_profiles',
                filter: {
                  bool: { must: values.map { |value| { term: { "user_profiles.category_ids" => value } } } }
                }
              }
            }
          end
        end
      end
    end
  end
end
