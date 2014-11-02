class AddCounterCachesToUserInstanceProfile < ActiveRecord::Migration
  class UserInstanceProfile < ActiveRecord::Base
    belongs_to :user
    has_many :reservations, through: :user
    has_many :transactables, through: :user, source: 'listings'
  end

  def up
    add_column :user_instance_profiles, :reservations_count, :integer, default: 0
    add_column :user_instance_profiles, :transactables_count, :integer, default: 0

    UserInstanceProfile.all.each do |profile|
      UserInstanceProfile.update_counters profile.id, reservations_count: profile.reservations.where(instance_id: profile.instance_id).count
      UserInstanceProfile.update_counters profile.id, transactables_count: profile.transactables.where(instance_id: profile.instance_id).count
    end
  end

  def down
    remove_column :user_instance_profiles, :transactables_count
    remove_column :user_instance_profiles, :reservations_count
  end
end
