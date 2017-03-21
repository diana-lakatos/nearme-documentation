class AddParameterizedNameDoInstanceProfileTypes < ActiveRecord::Migration
  def up
    PlatformContext.current = nil
    add_column :instance_profile_types, :parameterized_name, :string, index: true
    InstanceProfileType.reset_column_information
    InstanceProfileType.find_each { |ipt| ipt.update_column(:parameterized_name, InstanceProfileType.parameterize_name(ipt.name)) }
  end

  def down
    remove_column :instance_profile_types, :parameterized_name
  end
end
