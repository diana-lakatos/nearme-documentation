class RemoveCustomAttributeColumns < ActiveRecord::Migration
  def up
    Instance.find_each do |i|
      puts "Processing #{i.name}"
      i.set_context!

      custom_attributes = InstanceProfileType.first.custom_attributes.pluck(:name)
      User.where(instance_profile_type_id: InstanceProfileType.first.id).each do |u|
        custom_attributes.each do |attr|
          if u.respond_to?(attr) && u.properties[attr].blank? && u.read_attribute(attr).present?
            puts "Updating #{attr} for #{u.id} to value #{u.read_attribute(attr)} (#{u.properties[attr]})"
            u.properties[attr] = u.read_attribute(attr)
          end
        end
        u.save(validate: false)
      end
    end
    remove_column :users, :biography
    remove_column :users, :job_title
    remove_column :users, :skills_and_interests
    remove_column :users, :drivers_licence_number
    remove_column :users, :gov_number
    remove_column :users, :gender

    remove_column :users, :mailchimp_synchronized_at
  end

  def down
    add_column :users, :biography, :string
    add_column :users, :job_title, :string
    add_column :users, :skills_and_interests, :string
    add_column :users, :drivers_licence_number, :string
    add_column :users, :gov_number, :string
    add_column :users, :gender, :string

    add_column :users, :mailchimp_synchronized_at, :datetime
  end
end
