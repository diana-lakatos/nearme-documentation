class AddUpdatableIdUpdatableTypeToUserStatusUpdate < ActiveRecord::Migration
  def change
    add_column :user_status_updates, :updateable_id, :integer
    add_column :user_status_updates, :updateable_type, :string
    add_index :user_status_updates, [:updateable_id, :updateable_type], name: :usu_updateable

    UserStatusUpdate.where.not(instance_id: nil).find_each do |usu|
      usu.updateable = usu.user
      usu.save!
    end
  end
end
