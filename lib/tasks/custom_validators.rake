namespace :custom_validators do
  desc 'Create default custom validaotrs for User'
  task create_defaults_for_user: :environment do
    Instance.find_each do |instance|
      instance.set_context!
      p "Creating validators for Instance ##{instance.id}"
      # length restrictions for user's attributes
      length_fields = {first_name: User::MAX_NAME_LENGTH, middle_name: User::MAX_NAME_LENGTH, last_name: User::MAX_NAME_LENGTH,
                       current_location: 50,  company_name: 50}
      length_fields.each_pair do |field, size|
        instance.default_profile_type.custom_validators.create!(
          {
            field_name: field,
            max_length: size

          }
        )
      end

      #required fields for instance. Can belong to user nad custom attributes
      instance.user_required_fields.each do |field|
        if User.new.respond_to? field
          create_required_validator(instance.default_profile_type, field)
        elsif custom_attribute = instance.default_profile_type.custom_attributes.where(name: field).first
          custom_attribute.validation_rules ||= {}
          custom_attribute.validation_rules['presence'] = {}
          custom_attribute.save!
          p "Checked custom attribute as required: #{field}"
        else
          p "Couldn't find #{field} to create validator"
        end
      end

      #required fields for buyer profile
      %w(last_name phone).each do |field|
        create_required_validator(instance.buyer_profile_type, field)
      end

      #required fields for seller profile
      %w(phone).each do |field|
        create_required_validator(instance.seller_profile_type, field)
      end
    end
  end

  def create_required_validator(profile, field)
    profile.custom_validators.create!(
      {
        field_name: field,
        required: 1

      }
    )
  end
end
