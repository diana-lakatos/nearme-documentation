class CreateWorkplaces < ActiveRecord::Migration
  def self.up
    create_table :workplaces do |t|
      t.string  :name
      t.integer :maximum_desks
      t.text    :description
      t.text    :company_description
      t.text    :address
      t.boolean :confirm_bookings
      t.integer :creator_id
      t.float   :latitude
      t.float   :longitude
      t.timestamps
    end
  end

  def self.down
    drop_table :workplaces
  end
end
