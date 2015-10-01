class AddCommunityFlagToInstance < ActiveRecord::Migration
  def up
    add_column :instances, :is_community, :boolean, default: false
    Instance.find_by(id: 23).try(:update_column, :is_community, true)
  end

  def down
    remove_column :instances, :is_community
  end
end

