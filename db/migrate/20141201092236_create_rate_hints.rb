class CreateRateHints < ActiveRecord::Migration
  def change
    create_table :rate_hints do |t|
      t.string :value
      t.string :description
      t.references :rating_system, index: true

      t.timestamps
    end
  end
end
