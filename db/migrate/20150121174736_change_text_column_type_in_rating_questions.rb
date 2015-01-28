class ChangeTextColumnTypeInRatingQuestions < ActiveRecord::Migration
  def change
    change_column :rating_questions, :text, :text
  end
end
