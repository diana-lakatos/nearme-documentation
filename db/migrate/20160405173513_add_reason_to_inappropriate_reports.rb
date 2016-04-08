class AddReasonToInappropriateReports < ActiveRecord::Migration
  def change
    add_column :inappropriate_reports, :reason, :text
  end
end
