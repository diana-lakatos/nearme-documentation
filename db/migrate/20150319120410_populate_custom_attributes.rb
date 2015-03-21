class PopulateCustomAttributes < ActiveRecord::Migration
  def up
    Instance.find_each do |i|
      puts "Instance: #{i.name} ID: #{i.id}"
      PlatformContext.current = PlatformContext.new(i)
      instance_profile_type = InstanceProfileType.first
      field_names = instance_profile_type.custom_attributes.pluck(:name)
      tags = {biography: 'textarea', gender: 'select', skills_and_interests: 'textarea'}
      valid_values = {gender: ['male', 'female', 'unspecified']}
      %w(gender drivers_licence_number gov_number job_title skills_and_interests biography twitter_url linkedin_url facebook_url google_plus_url).each do |attr|
        usages = User.where("#{attr} is not null").count
        puts "ATTR: #{attr} #{field_names.include?(attr)} #{field_names.inspect} USERS: #{usages}"
        unless field_names.include?(attr)
          if usages > 0
            puts 'Creating custom attribute;'
            ca = instance_profile_type.custom_attributes.create({
              name: attr,
              attribute_type: 'string',
              html_tag: tags[attr] || 'input',
              required: '0',
              public: '1',
              label: attr.gsub('_', ' ').capitalize,
              valid_values: valid_values[attr] || []
            })
            puts ca.errors.messages
            ca.set_validation_rules
          else
            puts 'Skipping custom attribute;'
          end
        end
      end
      PlatformContext.current = nil
    end
  end

  def down; end
end