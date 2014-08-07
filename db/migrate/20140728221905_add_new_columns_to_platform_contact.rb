class AddNewColumnsToPlatformContact < ActiveRecord::Migration
  def change
    add_column :platform_contacts, :lead_source,       :string
    add_column :platform_contacts, :location,          :string
    add_column :platform_contacts, :previous_research, :string
  end
end
