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
                   prepopulator: ->(*) { send(:"#{instance_profile_name}=", find_instance_profile_type(instance_profile_name.to_s)) if send(:"#{instance_profile_name}").nil? },
                   populate_if_empty: ->(as:, **_options) { ipt = InstanceProfileType.find_by(parameterized_name: instance_profile_name.to_s); ipt.user_profiles.build(profile_type: ipt.parameterized_name) }
        end

        protected

        def find_instance_profile_type(parameterized_name)
          instance_profile_type = InstanceProfileType.find_by(parameterized_name: parameterized_name)
          raise ArgumentError, "Unknown instance profile type: #{parameterized_name}. Valid profile types: #{InstanceProfileType.pluck(:parameterized_name)}." if instance_profile_type.nil?
          instance_profile_type.user_profiles.build
        end
      end
    end
  end
end
