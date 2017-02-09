module Elastic
  class UserDrop < UserBaseDrop
    delegate :id, :avatar, :name, :slug, :tags, :created_at,
             :number_of_completed_orders_user, :number_of_completed_orders_creator,
             :click_to_call, :blog,
             :buyer_average_rating, :seller_average_rating,
             :reviews_counter, :current_address,
             to: :source

    # TODO: breaking changes - migrate liquids
    def profiles
      @__profiles ||= source.user_profiles.each_with_object({}) do |profile, profiles|
        profiles[profile.profile_type] = Elastic::ProfileDrop.new(profile)
      end
    end

    def tag_list
      source.tags.split(',')
    end
  end
end
