class AddMembersCountToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :members_count, :integer, default: 0, null: false
    Group.reset_column_information
    GroupMember.counter_culture_fix_counts
  end
end
