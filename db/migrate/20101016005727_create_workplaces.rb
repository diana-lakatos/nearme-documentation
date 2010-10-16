class CreateWorkplaces < ActiveRecord::Migration
  def self.up
    create_table :workplaces do |t|
      t.string  :name
      t.integer :maximum_desks
      t.text    :description
      t.text    :company_description
      t.text    :address
      t.float   :lat
      t.float   :lng
      t.boolean :confirm_bookings
      t.integer :creator_id
      t.timestamps
    end
  end

  def self.down
    drop_table :workplaces
  end
end
