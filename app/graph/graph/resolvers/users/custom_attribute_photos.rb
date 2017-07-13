# frozen_string_literal: true
module Graph
  module Resolvers
    class Users
      class CustomAttributePhotos < Resolvers::CustomAttributePhotosBase
        private

        def custom_images_ids(custom_images)
          user = Resolvers::User.find_model(object)
          profile_images = custom_images.where(owner: user.user_profiles)
          customization_images = custom_images.where(
            owner_type: ::Customization.to_s,
            owner_id: user.user_profiles.map { |user_profile| user_profile.customizations.map(&:id) }.flatten
          )
          profile_images.pluck(:id) + customization_images.pluck(:id)
        end
      end
    end
  end
end
