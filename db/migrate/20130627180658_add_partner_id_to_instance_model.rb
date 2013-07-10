class AddPartnerIdToInstanceModel < ActiveRecord::Migration

  def up
    add_column :instances, :partner_id, :integer
    
    connection.execute <<-SQL
      UPDATE instances 
      SET partner_id = 1
    SQL
  end

  def down
    remove_column :instances, :partner_id
  end
end
