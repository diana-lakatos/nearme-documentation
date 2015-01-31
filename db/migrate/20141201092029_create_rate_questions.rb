class CreateRateQuestions < ActiveRecord::Migration
  def change
    create_table :rate_questions do |t|
      t.string :text
      t.references :rating_system, index: true

      t.timestamps
    end
  end
end
