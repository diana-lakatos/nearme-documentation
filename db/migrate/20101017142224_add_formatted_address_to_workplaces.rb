class AddFormattedAddressToWorkplaces < ActiveRecord::Migration
  def self.up
    add_column :workplaces, :formatted_address, :string
  end

  def self.down
    remove_column :workplaces, :formatted_address
  end
end
