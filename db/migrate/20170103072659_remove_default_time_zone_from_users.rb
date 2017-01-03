class RemoveDefaultTimeZoneFromUsers < ActiveRecord::Migration
  def up
    change_column :users, :time_zone, :string, default: nil
  end

  def down
    change_column :users, :time_zone, :string, default: "Pacific Time (US & Canada)"
  end
end
