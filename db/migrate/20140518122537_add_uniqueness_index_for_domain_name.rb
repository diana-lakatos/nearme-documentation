class AddUniquenessIndexForDomainName < ActiveRecord::Migration
  def up
    add_index :domains, :name, unique: true, where: '(deleted_at IS NULL)'
    add_index :domains, :deleted_at
  end

  def down
    remove_index :domains, :name
    remove_index :domains, :deleted_at
  end
end
