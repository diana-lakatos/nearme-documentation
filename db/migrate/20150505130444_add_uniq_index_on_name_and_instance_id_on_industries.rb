class AddUniqIndexOnNameAndInstanceIdOnIndustries < ActiveRecord::Migration
  def change
    add_index :industries, %i(instance_id name), unique: true
  end
end
