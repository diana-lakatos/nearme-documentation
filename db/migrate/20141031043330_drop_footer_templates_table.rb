class DropFooterTemplatesTable < ActiveRecord::Migration
  def up
    drop_table :footer_templates
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
