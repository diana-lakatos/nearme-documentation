module ElasticIndexer
  class UserSerializer < BaseSerializer
    attributes :email, :first_name, :last_name, :name, :slug,
               :created_at, :deleted_at,
               :country_name, :company_name,
               :tags, :tag_list,
               :instance_id, :instance_profile_type_ids,
               :seller_average_rating, :buyer_average_rating,
               :click_to_call,
               :number_of_completed_orders_user,
               :number_of_completed_orders_creator,
               :featured,
               :geo_location, :geo_service_shape

    has_one :blog, serializer: UserBlogSerializer
    has_one :communication
    has_one :avatar, serializer: ImageUploaderSerializer
    has_one :current_address, serializer: AddressSerializer
    has_one :reviews_counter, serializer: ReviewAggregatorSerializer

    has_many :companies, serializer: CompanySerializer
    has_many :user_profiles, serializer: UserProfileSerializer

    def instance_profile_type_ids
      object.user_profiles.map(&:instance_profile_type_id)
    end

    def tags
      object.tags_as_comma_string
    end

    def tag_list
      object.tags.as_json(only: [:name, :slug])
    end

    def number_of_completed_orders_creator
      object.listing_orders.reviewable.count
    end

    def number_of_completed_orders_user
      object.orders.reviewable.count
    end

    def geo_location
      GeoLocationSerializer.new(object).as_json
    end

    def geo_service_shape
      GeoServiceShapeSerializer.new(object).as_json
    end

    private

    def latitude
      object.current_address.latitude.to_f
    end

    def longitude
      object.current_address.longitude.to_f
    end
  end
end
