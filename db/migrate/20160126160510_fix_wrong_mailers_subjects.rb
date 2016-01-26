class FixWrongMailersSubjects < ActiveRecord::Migration
  def change
    Rake::Task['fix:fix_wrong_mailers_subjects'].invoke
  end
end
