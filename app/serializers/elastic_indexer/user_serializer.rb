module ElasticIndexer
  class UserSerializer < BaseSerializer
    has_one :blog, serializer: UserBlogSerializer
    has_one :communication
    has_one :avatar, serializer: ImageUploaderSerializer
    has_one :current_address, serializer: AddressSerializer
    has_one :reviews_counter, serializer: ReviewAggregatorSerializer

    has_many :user_profiles, serializer: UserProfileSerializer

    attributes :click_to_call,
               :instance_profile_type_ids,
               :tags,
               :number_of_completed_orders_user,
               :number_of_completed_orders_creator,
               :featured

    def attributes
      super.merge __default_attributes
    end

    def instance_profile_type_ids
      object.user_profiles.map(&:instance_profile_type_id)
    end

    def tags
      object.tags_as_comma_string
    end

    def number_of_completed_orders_creator
      object.listing_orders.reviewable.count
    end

    def number_of_completed_orders_user
      object.orders.reviewable.count
    end

    private

    def __default_attributes
      object.as_json only: User.mappings.to_hash[:user][:properties].keys
    end
  end
end
