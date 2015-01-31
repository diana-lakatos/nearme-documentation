class RenameRatingTables < ActiveRecord::Migration
  def up
    rename_column :rate_answers, :rate_question_id, :rating_question_id

    rename_table :rate_questions, :rating_questions
    rename_table :rate_hints, :rating_hints
    rename_table :rate_answers, :rating_answers
  end

  def down
    rename_column :rating_answers, :rating_question_id, :rate_question_id

    rename_table :rating_questions, :rate_questions
    rename_table :rating_hints, :rate_hints
    rename_table :rating_answers, :rate_answers
  end
end
