# frozen_string_literal: true
module ElasticIndexer
  class UserProfileSerializer < BaseSerializer
    attributes :instance_profile_type_id,
               :profile_type,
               :enabled,
               :availability_exceptions,
               :onboarded_at,
               :category_ids, # legacy,
               :categories,
               :properties

    has_many :customizations, serializer: CustomModelSerializer
    has_many :custom_images, serializer: CustomImageSerializer
    has_one :availability_template, serializer: AvailabilityTemplateSerializer

    def properties
      CustomModelPropertySerializer.new(object.properties, scope: object.instance_profile_type).as_json
    end

    # TODO: test twice
    def availability_exceptions
      Time.use_zone(object.time_zone) do
        Array(object.availability_exceptions).map(&:all_dates).flatten
      end
    end

    def categories
      object.categories.order(:lft).map { |c| CategorySerializer.new(c).as_json }
    end
  end
end
