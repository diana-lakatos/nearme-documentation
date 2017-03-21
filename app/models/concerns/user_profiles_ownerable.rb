# frozen_string_literal: true
module UserProfilesOwnerable
  extend ActiveSupport::Concern
  included do
    has_many :user_profiles

    # FIXME: nead a cleaner solution - for now it's used by Form Object
    # to populate inputs
    def profiles_open_struct
      hash = {}
      InstanceProfileType.find_each do |instance_profile_type|
        hash[instance_profile_type.parameterized_name] = user_profiles.detect { |c| c.instance_profile_type_id == instance_profile_type.id }
      end
      OpenStruct.new(hash)
    end

    # FIXME: nead a cleaner solution - for now it's used by Form Object
    # to sync model with form after validation passes
    def profiles_open_struct=(open_struct)
      hash = profiles_open_struct.to_h.each_with_object({}) do |(instance_profile_type_name, values), ids_hash|
        ids_hash[instance_profile_type_name] = open_struct[instance_profile_type_name] || values
      end
      self.user_profiles = hash.values.compact
    end
  end
end
