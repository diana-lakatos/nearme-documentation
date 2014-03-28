class AddSercuredToDomains < ActiveRecord::Migration
  def change
    add_column :domains, :secured, :boolean, default: false
  end
end
