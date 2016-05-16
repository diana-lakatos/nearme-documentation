class MustHaveVerifiedPhoneNumberToInstanceProfiles < ActiveRecord::Migration
  def up
    add_column :instance_profile_types, :must_have_verified_phone_number, :boolean, default: false
    Instance.find_by(id: 175).try(:set_context!)
    InstanceProfileType.reset_column_information
    if PlatformContext.current.present?
      InstanceProfileType.seller.first.update_attribute(:must_have_verified_phone_number, true)
    end
  end

  def down
    remove_column :user_profiles, :must_have_verified_phone_number
  end
end
