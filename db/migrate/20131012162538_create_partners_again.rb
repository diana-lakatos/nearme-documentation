class CreatePartnersAgain < ActiveRecord::Migration
  def change
    create_table :partners do |t|
      t.string :name
      t.integer :instance_id
      t.timestamps
    end
  end
end
