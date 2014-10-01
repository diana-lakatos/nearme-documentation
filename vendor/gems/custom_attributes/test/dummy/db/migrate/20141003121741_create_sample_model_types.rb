class CreateSampleModelTypes < ActiveRecord::Migration
  def change
    create_table :sample_model_types do |t|
      t.string :name
      t.timestamps
    end
  end
end
