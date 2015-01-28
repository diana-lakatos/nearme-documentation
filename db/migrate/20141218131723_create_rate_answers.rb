class CreateRateAnswers < ActiveRecord::Migration
  def change
    create_table :rate_answers do |t|
      t.integer :rating
      t.references :rate_question, index: true
      t.references :review, index: true

      t.timestamps
    end
  end
end
