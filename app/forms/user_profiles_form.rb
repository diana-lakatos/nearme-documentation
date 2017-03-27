# frozen_string_literal: true
class UserProfilesForm < BaseForm
  class << self
    def decorate(configuration)
      Class.new(self) do
        configuration.each do |instance_profile_name, fields|
          validation = fields.delete(:validation)
          validates :"#{instance_profile_name}", validation if validation.present?
          property :"#{instance_profile_name}",
                     form: UserProfileForm.decorate(fields),
                     prepopulator: ->(*) { send(:"#{instance_profile_name}=", InstanceProfileType.find_by(parameterized_name: instance_profile_name.to_s).user_profiles.build) if send(:"#{instance_profile_name}").nil? },
                     populate_if_empty: ->(as:, **_options) { ipt = InstanceProfileType.find_by(parameterized_name: instance_profile_name.to_s); ipt.user_profiles.build(profile_type: ipt.parameterized_name) }

        end
      end
    end
  end
end
