class AddTimestampsToAttributes < ActiveRecord::Migration
  def change
    change_table :transactable_type_attributes do |t|
      t.timestamps
    end
  end
end
