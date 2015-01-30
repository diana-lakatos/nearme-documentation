class AddInstanceIdToRatingModels < ActiveRecord::Migration
  def change
    add_reference :rating_answers, :instance, index: true

    add_reference :rating_hints, :instance, index: true

    add_reference :rating_questions, :instance, index: true
  end
end
