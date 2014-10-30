class AddCounterCachesToUserInstanceProfile < ActiveRecord::Migration
  def up
    add_column :user_instance_profiles, :reservations_count, :integer, default: 0
    add_column :user_instance_profiles, :transactables_count, :integer, default: 0

    UserInstanceProfile.reset_column_information
    UserInstanceProfile.all.each do |profile|
      UserInstanceProfile.update_counters profile.id, reservations_count: profile.reservations.length
      UserInstanceProfile.update_counters profile.id, transactables_count: profile.transactables.length
    end
  end

  def down
    remove_column :user_instance_profiles, :transactables_count
    remove_column :user_instance_profiles, :reservations_count
  end
end
