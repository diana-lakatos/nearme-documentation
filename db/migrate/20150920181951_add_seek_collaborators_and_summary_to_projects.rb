class AddSeekCollaboratorsAndSummaryToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :seek_collaborators, :boolean, default: false
    add_column :projects, :summary, :text
  end
end
