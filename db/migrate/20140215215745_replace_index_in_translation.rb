class ReplaceIndexInTranslation < ActiveRecord::Migration
  def up
    remove_index :translations, :instance_id
    add_index :translations, [:instance_id, :updated_at]
  end

  def down
    add_index :translations, :instance_id
    remove_index :translations, [:instance_id, :updated_at]
  end
end
