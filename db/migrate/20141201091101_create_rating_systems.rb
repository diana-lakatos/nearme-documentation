class CreateRatingSystems < ActiveRecord::Migration
  def change
    create_table :rating_systems do |t|
      t.string :subject
      t.references :service, index: true

      t.timestamps
    end
  end
end
