class CreateActionTypes < ActiveRecord::Migration

  class ActionType < ActiveRecord::Base
    validates_uniqueness_of :name
  end

  def change
    create_table :action_types do |t|
      t.string :name
      t.datetime :deleted_at
      t.timestamps
    end

    create_table :transactable_type_actions do |t|
      t.integer :action_type_id, index: true
      t.integer :transactable_type_id, index: true
      t.integer :instance_id, index: true
      t.datetime :deleted_at
      t.timestamps
    end

    ActionType.create(name: 'Request For Quote') unless ActionType.where(name: 'Request For Quote').count > 0
  end
end

